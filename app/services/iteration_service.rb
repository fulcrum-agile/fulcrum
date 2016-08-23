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
    @stories = project.stories.includes(:owned_by).to_a

    @accepted_stories = @stories.
      select { |story| story.column == '#done' }.
      select { |story| story.accepted_at < iteration_start_date(Time.current) }
    calculate_iterations!
    fix_owner!

    @backlog = ( @stories - @accepted_stories ).sort_by(&:position)
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

  def velocity
    @velocity ||= begin
      iterations = group_by_iteration.size
      iterations = VELOCITY_ITERATIONS if iterations > VELOCITY_ITERATIONS

      sum = group_by_velocity.values.slice((-1 * iterations)..-1).
        reduce(&:+)
      stories = group_by_iteration.values.slice((-1 * iterations)..-1).
        map { |stories| stories.size }.
        reduce(&:+)

      velocity = (sum / stories).floor
      velocity < 1 ? 1 : velocity
    end
  end

  def group_by_developer
    @group_by_developer ||= @accepted_stories.
      group_by { |story| story.owned_by.name }.
      reduce([]) do |group, owner|
        data = owner.last.group_by { |story| story.iteration_number }.
          reduce({}) do |group, iteration|
            group.merge(iteration.first => stories_estimates(iteration.last).
                        reduce(&:+))
          end
        group << { name: owner.first, data: data }
      end
  end

  def backlog_iterations
    # mimics the project.js rebuildIteration() function
    @backlog_iterations ||= begin
      current_iteration = Iteration.new(self, current_iteration_number, velocity)
      backlog_iteration = Iteration.new(self, current_iteration_number + 1, velocity)
      [current_iteration, backlog_iteration].tap do |iterations|
        @backlog.each do |story|
          if current_iteration.can_take_story?(story)
            current_iteration << story
          else
            if !backlog_iteration.can_take_story?(story)
              # Iterations sometimes 'overflow', i.e. an iteration may contain a
              # 5 point story but the project velocity is 1.  In this case, the
              # next iteration that can have a story added is the current + 4.
              next_number       = backlog_iteration.number + 1 + (backlog_iteration.overflows_by / velocity).ceil
              backlog_iteration = Iteration.new(self, next_number, velocity)
              iterations << backlog_iteration
            end
            backlog_iteration << story
          end
        end
      end
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

  def iteration_details(iteration)
    {
      points: iteration.reduce(0) { |total, story| total + (story.estimate || 0) },
      count: iteration.size,
      non_estimable: iteration.select { |story| !Story::ESTIMABLE_TYPES.include?(story.story_type) }.size
    }
  end
end

