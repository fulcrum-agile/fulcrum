require 'test_helper'

class ProjectsHelperTest < ActionView::TestCase
  def setup
    @project = FactoryGirl.create(:project)
  end

  test "should return point scale options for select" do
    # Should be an array of arrays
    assert_instance_of Array, point_scale_options
    point_scale_options.each do |option|
      assert_instance_of Array, option
    end
  end

  test "should return iteration length options for select" do
    assert_instance_of Array, iteration_length_options
    iteration_length_options.each do |option|
      assert_instance_of Array, option
    end
  end

  test "should return day name options for select" do
    assert_instance_of Array, day_name_options
    day_name_options.each do |option|
      assert_instance_of Array, option
    end
  end
end
