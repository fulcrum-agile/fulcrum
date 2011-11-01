require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  def setup
    @project = Factory.create(:project)
  end

  test "should not save a project without a name" do
    @project.name = ""
    assert !@project.save
    assert_equal ["can't be blank"], @project.errors[:name]
  end

  test "should return a string" do
    assert_equal @project.name, @project.to_s
  end

  test "default point scale should be fibonacci" do
    assert_equal 'fibonacci', Project.new.point_scale
  end

  test "default velocity should be 10" do
    assert_equal 10, Project.new.default_velocity
  end

  test "default velocity must be greater than 0" do
    @project.default_velocity = 0
    assert !@project.valid?
    assert_equal ["must be greater than 0"], @project.errors[:default_velocity]
  end

  test "default velocity must be an integer" do
    @project.default_velocity = 1.5
    assert !@project.valid?
    assert_equal ["must be an integer"], @project.errors[:default_velocity]
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

  test "should return the id of the most recent changeset" do
    assert_equal nil, @project.last_changeset_id
    user = Factory.create(:user)
    @project.users << user
    story = Factory.create(:story, :project => @project, :requested_by => @user)
    assert_equal Changeset.last.id, @project.last_changeset_id
  end

  test "should return json" do
    attrs = [
      "id", "point_values", "last_changeset_id", "iteration_length",
      "iteration_start_day", "start_date", "default_velocity"
    ]
    assert_returns_json attrs, @project
  end

  test "should set the start date when starting the first story" do
    assert_nil @project.start_date
    story = Factory.create(:story, :project => @project, :requested_by => @user)
    story.update_attribute :state, 'started'
    assert_equal Date.today, @project.start_date
  end

  test "should cascade delete stories" do
    story = Factory.create(:story, :project => @project, :requested_by => @user)
    assert_equal @project.stories.count, 1
    assert_difference 'Story.count', -1 do
      assert @project.destroy
    end
  end

  test "should cascade delete changesets" do
    story = Factory.create(:story, :project => @project, :requested_by => @user)
    assert_equal @project.changesets.count, 1
    assert_difference 'Changeset.count', -1 do
      assert @project.destroy
    end
  end

  test "should return the projects csv filename" do
    assert_match /^Test Project-\d{8}_\d{4}\.csv$/, @project.csv_filename
  end

  test "suppress notifications should default to false" do
    assert_equal false, @project.suppress_notifications
  end
end
