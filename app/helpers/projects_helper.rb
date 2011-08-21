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
      [pluralize(weeks, "week"), weeks]
    end
  end

  # Returns an array of day name options suitable for use in
  # a select helper.  The values are 0 to 6, with 0 being Sunday.
  def day_name_options
    DateTime::DAYNAMES.each_with_index.collect{|name,i| [name,i]}
  end
end
