class IterationService
  DAYS_IN_WEEK = (1.week / 1.day)
  FIELDS = [:id, :estimate, :accepted_at, :story_type]

  attr_reader :project, :stories

  delegate :start_date, :start_date=,
    :iteration_length, :iteration_length=,
    :iteration_start_day, :iteration_start_day=,
    to: :project

  def initialize(project)
    @project = project
    @stories = project.stories.
      where.not(accepted_at: nil).
      order(:accepted_at).
      pluck(*FIELDS)
  end

  def iteration_start_date
    iteration_start_date = start_date.beginning_of_day
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

  def stories_hash
    @stories.
      map { |record| Hash[FIELDS.zip(record)] }.
      map do |hash|
        iteration_number = iteration_number_for_date(hash[:accepted_at])
        iteration_start_date = date_for_iteration_number(iteration_number)
        hash.merge(
          iteration_number: iteration_number,
          iteration_start_date: iteration_start_date)
      end
  end

  def group_by_velocity
    stories_hash.
      group_by { |o| o[:iteration_start_date] }.
      inject({}) { |group, iteration| group.merge(iteration.first.to_date => iteration.last.size) }
  end
end
