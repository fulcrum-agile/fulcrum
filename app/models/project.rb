class Project < ActiveRecord::Base
  # These are the valid point scalse for a project.  These represent
  # the set of valid points estimate values for a story in this project.
  POINT_SCALES = {
    'fibonacci'     => [0,1,2,3,5,8],
    'powers_of_two' => [0,1,2,4,8],
    'linear'        => [0,1,2,3,4,5],
  }
  validates_inclusion_of :point_scale, :in => POINT_SCALES.keys,
    :message => "%{value} is not a valid estimation scheme"

  ITERATION_LENGTH_RANGE = (1..4)
  validates_numericality_of :iteration_length,
    :greater_than_or_equal_to => ITERATION_LENGTH_RANGE.min,
    :less_than_or_equal_to => ITERATION_LENGTH_RANGE.max, :only_integer => true,
    :message => "must be between 1 and 4 weeks"

  validates_numericality_of :iteration_start_day,
    :greater_than_or_equal_to => 0, :less_than_or_equal_to => 6,
    :only_integer => true, :message => "must be an integer between 0 and 6"

  has_and_belongs_to_many :users, :uniq => true
  accepts_nested_attributes_for :users, :reject_if => :all_blank

  has_many :stories

  # Returns an array of the valid points values for this project
  def point_values
    POINT_SCALES[point_scale]
  end
end
