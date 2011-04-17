require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  def setup
    @project = Factory.create(:project)
  end

  test "default point scale should be fibonacci" do
    assert_equal 'fibonacci', Project.new.point_scale
  end

  test "should reject invalid point scale" do
    @project.point_scale = 'invalid_point_scale'
    assert !@project.save
  end

  test "should return the valid values for point scale" do
    assert_equal [0,1,2,3,5,8], @project.point_values
  end

  test "default iteration length should be 1 week" do
    assert_equal 1, Project.new.iteration_length
  end

  test "should reject invalid iteration lengths" do
    @project.iteration_length = 0
    assert !@project.save
    @project.iteration_length = 5
    assert !@project.save
    # Must be an integer
    @project.iteration_length = 2.5
    assert !@project.save
  end

  test "default iteration start day should be Monday" do
    assert_equal 1, Project.new.iteration_start_day
  end

  test "should reject invalid iteration start days" do
    @project.iteration_start_day = -1
    assert !@project.save
    @project.iteration_start_day = 7
    assert !@project.save
    # Must be an integer
    @project.iteration_start_day = 2.5
    assert !@project.save
  end
end
