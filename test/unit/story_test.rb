require 'test_helper'

class StoryTest < ActiveSupport::TestCase
  def setup
    @user = Factory.create(:user)
    @project = Factory.create(:project, :users => [@user])
    @story = Factory.create(:story, :project => @project,
                            :requested_by => @user)
  end

  test "should return title from to_s" do
    assert_equal @story.title, @story.to_s
  end

  test "state should default to unstarted" do
    assert_equal "unstarted", Story.new.state
  end

  test "state must be one of the allowed values" do
    @story.state = "flum"
    assert !@story.save
  end

  test "story type should default to feature" do
    assert_equal "feature", Story.new.story_type
  end

  test "should not save without a story type" do
    @story.story_type = nil
    assert !@story.save
  end

  test "story type must be in the allowed values" do
    @story.story_type = 'flum'
    assert !@story.save
  end

  test "should not save without a project" do
    @story.project = nil
    assert !@story.save
  end

  test "requestor must belong to project" do
    user = Factory.create(:user)
    @story.requested_by = user
    assert !@story.save
  end

  test "estimate must be valid for project point scale" do
    @story.project.point_scale = 'fibonacci'
    @story.estimate = 4 # not in the fibonacci series
    assert !@story.save
    assert_equal "is not an allowed value for this project",
      @story.errors[:estimate].first
  end

  test "should check if estimated" do
    assert !@story.estimated?
    @story.estimate = 0
    assert @story.estimated?
  end

  test "should check if the story is estimable" do
    @story.story_type = 'feature'
    assert @story.estimable?
    @story.estimate = 1
    assert !@story.estimable?
    ['chore', 'bug', 'release'].each do |st|
      @story.story_type = st
      assert !@story.estimable?
    end
  end

  test "should return events for current state" do
    assert_equal [:start], @story.events
    @story.start
    assert_equal [:finish], @story.events
    @story.finish
    assert_equal [:deliver], @story.events
    @story.deliver
    assert_equal [:accept, :reject], @story.events
  end

  test "should return the css id of the column the story belongs in" do
    assert_equal '#backlog', @story.column
    @story.state = 'started'
    assert_equal '#in_progress', @story.column
    @story.state = 'finished'
    assert_equal '#in_progress', @story.column
    @story.state = 'delivered'
    assert_equal '#in_progress', @story.column
    @story.state = 'rejected'
    assert_equal '#in_progress', @story.column
    @story.state = 'accepted'
    assert_equal '#done', @story.column
  end
end
