class IterationService
  DAYS_IN_WEEK = (1.week / 1.day)

  attr_reader :project, :stories

  delegate :start_date, :start_date=,
    :iteration_length, :iteration_length=,
    :iteration_start_day, :iteration_start_day=,
    to: :project

  def initialize(project, since = nil)
    @project = project
    @stories = accepted_stories(since).to_a
    calculate_iterations!
    fix_owner!
  end

  def accepted_stories(since = nil)
    relation = project.stories.includes(:owned_by).
      where.not(accepted_at: nil).
      order(:accepted_at).
      where("accepted_at < ?", iteration_start_date(Time.current))

    relation = relation.where("accepted_at > ?", since) if since
    relation
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
    compare_date = compare_date.to_time if compare_date.is_a?(Date)
    days_apart = ( compare_date - iteration_start_date ) / 1.day
    days_in_iteration = iteration_length * DAYS_IN_WEEK
    ( days_apart / days_in_iteration ).floor + 1
  end

  def date_for_iteration_number(iteration_number)
    difference = (iteration_length * DAYS_IN_WEEK) * (iteration_number - 1)
    iteration_start_date + difference.days
  end

  def current_iteration
    iteration_number_for_date(Time.current)
  end

  def calculate_iterations!
    @stories.each do |record|
      iteration_number = iteration_number_for_date(record.accepted_at)
      iteration_start_date = date_for_iteration_number(iteration_number)
      record.iteration_number = iteration_number
      record.iteration_start_date = iteration_start_date
    end
  end

  # FIXME must figure out why the Story allows a nil owner in delivered states
  def fix_owner!
    @dummy_user ||= User.find_or_create_by!(username: "dummy", email: "dummy@foo.com", name: "Dummy", initials: "XX")
    @stories.
      select { |record| record.owned_by.nil? }.
      each   { |record| record.owned_by = @dummy_user }
  end

  def group_by_iteration
    @group_by_iteration ||= @stories.
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
    @group_by_velocity ||= group_by_iteration.keys.reduce({}) do |group, key|
      begin
        group.merge(key => group_by_iteration[key].reduce(&:+))
      rescue => e
        # FIXME should investigate why this fails (nil estimate on estimable stories)
        Rails.logger.error("[IterationService#group_by_velocity] #{key} #{group_by_iteration[key]}")
      end
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
    @group_by_bugs ||= begin
      by_bugs = @stories.
        group_by { |story| story.iteration_number }.
        reduce({}) do |group, iteration|
          group.merge(iteration.first => bugs_impact(iteration.last))
        end
      by_bugs.reduce({}) do |group, iteration|
        begin
          group.merge(iteration.first => iteration.last.reduce(&:+))
        rescue => e
          # FIXME should investigate why this fails (nil estimate on estimable stories)
          Rails.logger.error("[IterationService#group_by_bugs] #{key} #{iteration.last}")
        end
      end
    end
  end

  def velocity
    @velocity ||= begin
      iterations = group_by_iteration.size
      iterations = 3 if iterations > 3

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
    @group_by_developer ||= @stories.
      group_by { |o| o.owned_by.name }.
      reduce([]) do |group, owner|
        data = owner.last.group_by { |story| story.iteration_number }.
          reduce({}) do |group, iteration|
            group.merge(iteration.first => stories_estimates(iteration.last).
                        reduce(&:+))
          end
        group << { name: owner.first, data: data }
      end
  end
end
