module ProjectsHelper
  # Returns an array of valid project point scales suitable for
  # use in a select helper.
  def point_scale_options
    Project::POINT_SCALES.collect do |name,values|
      ["#{name.humanize} (#{values.join(',')})", name]
    end
  end

  # Returns an array of valid iteration length options suitable for use in
  # a select helper.
  def iteration_length_options
    (1..4).collect do |weeks|
      [I18n.t('n weeks', count: weeks), weeks]
    end
  end

  # Returns an array of day name options suitable for use in
  # a select helper.  The values are 0 to 6, with 0 being Sunday.
  def day_name_options
    I18n.t('date.day_names').each_with_index.collect{|name,i| [name,i]}
  end

  #
  # IterationService related helpers
  #
  def current_month
    (@service.current_iteration_number / 4).floor
  end

  def since_options
    if current_month > 6
      [1,3,6]
    elsif current_month > 3
      [1,3]
    else
      []
    end
  end

  def current_iteration_start_date
    @service.date_for_iteration_number(@service.current_iteration_number).to_date.to_s(:short)
  end

  def current_iteration_end_date
    (@service.date_for_iteration_number(@service.current_iteration_number + 1) - 1.day).to_date.to_s(:short)
  end

  def current_iteration
    @service.backlog_iterations.first.details
  end

  def current_iteration_points
    current_iteration[:points]
  end

  def current_iteration_count
    current_iteration[:count]
  end

  def current_iteration_non_estimable
    current_iteration[:non_estimable]
  end

  def accepted_points
    @service.current_iteration_details['accepted']
  end

  def accepted_rate
    if current_iteration_points == 0
      number_to_percentage(0, precision: 2)
    else
      number_to_percentage(( accepted_points.to_f * 100.0 ) / current_iteration_points.to_f, precision: 2)
    end
  end

  def last_iteration_number(worst = false)
    iterations = if worst
                   velocity       = @service.velocity
                   volatility     = @service.volatility
                   worst_velocity = velocity - ( velocity * volatility )
                   @service.backlog_iterations(worst_velocity.floor)
                 else
                   @service.backlog_iterations
                 end
    iterations.last.number
  end

  def last_iteration_start_date(worst = false)
    iterations = if worst
                   velocity       = @service.velocity
                   volatility     = @service.volatility
                   worst_velocity = velocity - ( velocity * volatility )
                   @service.backlog_iterations(worst_velocity.floor)
                 else
                   @service.backlog_iterations
                 end
    iterations.last.start_date.to_date.to_s(:long)
  end
end
