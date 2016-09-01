class IterationService
  DAYS_IN_WEEK = (1.week / 1.day)
  VELOCITY_ITERATIONS = 3

  attr_reader :project

  delegate :start_date, :start_date=,
    :iteration_length, :iteration_length=,
    :iteration_start_day, :iteration_start_day=,
    to: :project

  def initialize(project, since = nil)
    @project = project

    relation = project.stories.includes(:owned_by)
    relation = relation.where('accepted_at > ? or accepted_at is null', since) if since
    @stories = relation.to_a

    @accepted_stories = @stories.
      select { |story| story.column == '#done' }.
      select { |story| story.accepted_at < iteration_start_date(Time.current) }

    calculate_iterations!
    fix_owner!

    @stories.each { |s| s.iteration_service = self }
    @backlog = ( @stories - @accepted_stories.select { |s| s.column == '#done' } ).sort_by(&:position)
  end

  def iteration_start_date(date = nil)
    date = start_date if date.nil?
    iteration_start_date = date.beginning_of_day
    if start_date.wday != iteration_start_day
      day_difference = start_date.wday - iteration_start_day
      day_difference += DAYS_IN_WEEK if day_difference < 0

      iteration_start_date -= day_difference.days
    end
    iteration_start_date
  end

  def iteration_number_for_date(compare_date)
    compare_date      = compare_date.to_time if compare_date.is_a?(Date)
    days_apart        = ( compare_date - iteration_start_date ) / 1.day
    days_in_iteration = iteration_length * DAYS_IN_WEEK
    ( days_apart / days_in_iteration ).floor + 1
  end

  def date_for_iteration_number(iteration_number)
    difference = (iteration_length * DAYS_IN_WEEK) * (iteration_number - 1)
    iteration_start_date + difference.days
  end

  def current_iteration_number
    iteration_number_for_date(Time.current)
  end

  def calculate_iterations!
    @accepted_stories.each do |record|
      iteration_number            = iteration_number_for_date(record.accepted_at)
      iteration_start_date        = date_for_iteration_number(iteration_number)
      record.iteration_number     = iteration_number
      record.iteration_start_date = iteration_start_date
    end
  end

  # FIXME must figure out why the Story allows a nil owner in delivered states
  def fix_owner!
    @dummy_user ||= User.find_or_create_by!(username: "dummy", email: "dummy@foo.com", name: "Dummy", initials: "XX")
    @accepted_stories.
      select { |record| record.owned_by.nil? }.
      each   { |record| record.owned_by = @dummy_user }
  end

  def group_by_iteration
    @group_by_iteration ||= @accepted_stories.
      group_by { |story| story.iteration_number }.
      reduce({}) do |group, iteration|
        group.merge(iteration.first => stories_estimates(iteration.last))
      end
  end

  def stories_estimates(stories)
    stories.map do |story|
      if Story::ESTIMABLE_TYPES.include? story.story_type
        story.estimate || 0
      else
        0
      end
    end
  end

  def group_by_velocity
    @group_by_velocity ||= group_by_iteration.reduce({}) do |group, iteration|
      group.merge(iteration.first => iteration.last.reduce(&:+))
    end
  end

  def bugs_impact(stories)
    stories.map do |story|
      if Story::ESTIMABLE_TYPES.include? story.story_type
        0
      else
        1
      end
    end
  end

  def group_by_bugs
    @group_by_bugs ||=  @accepted_stories.
      group_by { |story| story.iteration_number }.
      reduce({}) do |group, iteration|
        group.merge(iteration.first => bugs_impact(iteration.last))
      end.
      reduce({}) do |group, iteration|
        group.merge(iteration.first => iteration.last.reduce(&:+))
      end
  end

  def velocity(number_of_iterations = VELOCITY_ITERATIONS)
    @velocity ||= {}
    @velocity[number_of_iterations] ||= begin
      number_of_iterations = group_by_iteration.size if number_of_iterations > group_by_iteration.size
      return 1 if number_of_iterations.zero?

      sum = group_by_velocity.values.slice((-1 * number_of_iterations)..-1).sum

      velocity = (sum / number_of_iterations).floor
      velocity < 1 ? 1 : velocity
    end
  end

  def group_by_developer
    @group_by_developer ||= begin
      min_iteration = @accepted_stories.map(&:iteration_number).min
      max_iteration = @accepted_stories.map(&:iteration_number).max
      @accepted_stories.
        group_by { |story| story.owned_by.name }.
        map do |owner|
          # all multiple series must have all the same keys or they will mess the graph
          data = (min_iteration..max_iteration).reduce({}) { |group, key| group.merge(key => 0)}
          owner.last.group_by { |story| story.iteration_number }.
            each do |iteration|
              data[iteration.first] = stories_estimates(iteration.last).reduce(&:+)
            end
          { name: owner.first, data: data }
        end
    end
  end

  def backlog_iterations(velocity_value = velocity)
    velocity_value = 1 if velocity_value < 1
    @backlog_iterations ||= {}
    # mimics the project.js rebuildIteration() function
    @backlog_iterations[velocity_value] ||= begin
      current_iteration = Iteration.new(self, current_iteration_number, velocity_value)
      backlog_iteration = Iteration.new(self, current_iteration_number + 1, velocity_value)
      iterations = [current_iteration, backlog_iteration]
      @backlog.each do |story|
        if current_iteration.can_take_story?(story)
          current_iteration << story
        else
          if !backlog_iteration.can_take_story?(story)
            # Iterations sometimes 'overflow', i.e. an iteration may contain a
            # 5 point story but the project velocity is 1.  In this case, the
            # next iteration that can have a story added is the current + 4.
            next_number       = backlog_iteration.number + 1 + (backlog_iteration.overflows_by / velocity_value).ceil
            backlog_iteration = Iteration.new(self, next_number, velocity_value)
            iterations << backlog_iteration
          end
          backlog_iteration << story
        end
      end
      iterations
    end
  end

  def current_iteration_details
    current_iteration = backlog_iterations.first
    %w(started finished delivered accepted rejected).reduce({}) do |data, state|
      data.merge(state => current_iteration.
                 select { |story| story.state == state }.
                 reduce(0) { |points, story| points + (story.estimate || 0) } )
    end
  end

  def standard_deviation(groups = [], sample = false)
    return 0 if groups.empty?
    # algorithm: https://www.mathsisfun.com/data/standard-deviation-formulas.html
    #
    mean            = groups.sum.to_f / groups.size.to_f
    differences_sqr = groups.map { |velocity| (velocity.to_f - mean) ** 2 }
    count = sample ? (groups.size - 1).to_f : groups.size.to_f
    variance        = differences_sqr.sum / count

    Math.sqrt(variance)
  end

  def volatility(number_of_iterations = VELOCITY_ITERATIONS)
    number_of_iterations = group_by_velocity.size if number_of_iterations > group_by_velocity.size

    is_sample       = number_of_iterations != group_by_velocity.size
    last_iterations = group_by_velocity.values.reverse.take(number_of_iterations)
    std_dev         = standard_deviation(last_iterations, is_sample)
    velocity_value  = velocity(number_of_iterations)

    ( std_dev / velocity_value )
  end
end

