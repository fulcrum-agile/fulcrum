class Entities::Project < Entities::BaseEntity
  expose :id
  expose :name
  expose :slug
  expose :point_scale
  expose :iteration_start_day
  expose :iteration_length
  expose :default_velocity
  expose :velocity, if: { type: :full }
  expose :volatility, if: { type: :full }
  expose :teams

  with_options(format_with: :iso_timestamp) do
    expose :created_at, if: lambda { |i, o| i.created_at.present? }
    expose :start_date, if: lambda { |i, o| i.start_date.present? }
  end

  private

  def velocity
    iteration_service.velocity
  end

  def volatility
    iteration_service.volatility
  end

  def iteration_service
    @iteration_service ||= begin
      object.iteration_service(since: options[:since].to_i.months.ago)
    end
  end

  def teams
    object.teams
  end
end
