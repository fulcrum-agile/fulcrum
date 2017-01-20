class Entities::ProjectAnalysis < Entities::BaseEntity
  expose :velocity
  expose :volatility
  expose :current_iteration_number
  expose :next_iteration_date
  expose :backlog
  expose :backlog_iterations
  expose :current_iteration_details
  expose :backlog_date
  expose :worst_backlog_date

  private

  def next_iteration_date
    last_iteration_number = object.current_iteration_number + 1

    object.date_for_iteration_number(last_iteration_number)
  end

  def worst_backlog_date
    object.backlog_date(true)
  end
end
