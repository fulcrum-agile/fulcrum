# mimics the iteration.js counterpart
class Iteration < Array
  attr_reader :start_date, :number, :maximum_points

  def initialize(service, iteration_number, maximum_points = nil)
    @service        = service
    @number         = iteration_number
    @maximum_points = maximum_points
    @is_full        = false
    super([])
  end

  def points
    self.reduce(0) { |total, story| total + ( story.estimate || 0 ) }
  end

  def available_points
    maximum_points - points
  end

  def can_take_story?(story)
    return true if %w(started finished delivered accepted rejected).include? story.state
    return false if @is_full
    return true if points == 0
    return true if story.story_type != 'feature'

    @is_full = (story.estimate || 0) > available_points
    !@is_full
  end

  def overflows_by
    difference = points - maximum_points
    difference < 0 ? 0 : difference
  end

  def start_date
    @service.date_for_iteration_number(@number)
  end

  def details
    {
      points: self.reduce(0) { |total, story| total + (story.estimate || 0) },
      count: self.size,
      non_estimable: self.select { |story| !Story::ESTIMABLE_TYPES.include?(story.story_type) }.size
    }
  end
end
