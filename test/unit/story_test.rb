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

  test "should not save without a title" do
    @story.title = ''
    assert !@story.save
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

  test "owner must belong to project" do
    user = Factory.create(:user)
    @story.owned_by = user
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
    assert @story.events.include?(:accept)
    assert @story.events.include?(:reject)
    assert_equal 2, @story.events.length
  end

  test "should return the css id of the column the story belongs in" do
    assert_equal '#backlog', @story.column
    @story.state = 'unscheduled'
    assert_equal '#chilly_bin', @story.column
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

  test "should return json" do
    attrs = [
      "title", "accepted_at", "created_at", "updated_at", "description",
      "project_id", "story_type", "owned_by_id", "requested_by_id", "estimate",
      "state", "position", "id", "events", "estimable", "estimated", "errors"
    ]

    assert_returns_json attrs, @story
  end

  test "should set a new story position to last in list" do
    project = Factory.create(:project, :users => [@user])
    story = Factory.create(:story, :project => project, :requested_by => @user)
    assert_equal 1, story.position
    story = Factory.create(:story, :project => project, :requested_by => @user)
    assert_equal 2, story.position
    story = Factory.create(:story, :project => project, :requested_by => @user,
                          :position => 1.5)
    assert_equal 1.5, story.position
  end

  test "should set accepted at when accepted" do
    assert_nil @story.accepted_at
    @story.update_attribute :state, 'accepted'
    assert_equal Date.today, @story.accepted_at
  end

  test "should not set accepted at when accepted if already set" do
    date = @story.accepted_at = Date.parse('1999/01/01')
    @story.update_attribute :state, 'accepted'
    assert_equal date, @story.accepted_at
  end

  test "should unset accepted at when changing from accepted" do
    @story.update_attribute :state, 'accepted'
    assert_not_nil @story.accepted_at
    @story.update_attribute :state, 'started'
    assert_nil @story.accepted_at
  end

  # If a story has an accepted date prior to the project start date,
  # reset the project start date
  test "should set project start date if accepted at is prior" do
    @project.start_date = Date.parse('2001/01/02')
    @story.update_attribute :accepted_at, Date.parse('2001/01/01')
    assert_equal @story.accepted_at, @project.start_date
  end

  test "modifying a story should create a new changeset" do
    assert_difference 'Changeset.count' do
      @story.update_attribute :title, 'New title to test changeset'
    end
  end

  test "creating a story should create a new changeset" do
    assert_difference 'Changeset.count' do
      Factory.create(:story, :project => @project, :requested_by => @user)
    end
  end

  test "delivering a story sends an email to the requestor" do
    @story.acting_user = Factory.create(:user)
    @project.users << @story.acting_user
    assert_difference 'ActionMailer::Base.deliveries.size' do
      @story.update_attribute :state, 'delivered'
    end
  end

  test "delivering a story sends no email if requested by is not set" do
    @story.acting_user = Factory.create(:user)
    @project.users << @story.acting_user
    @story.requested_by = nil
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      @story.update_attribute :state, 'delivered'
    end
  end

  test "delivering a story sends no email if acting user is not set" do
    @story.acting_user = nil
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      @story.update_attribute :state, 'delivered'
    end
  end

  test "delivering a story sends no email if acting user was the requestor" do
    @story.acting_user = @story.requested_by
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      @story.update_attribute :state, 'delivered'
    end
  end

  ["accept", "reject"].each do |action|

    test "#{action}ing a story sends an email to the owner" do
      @story.acting_user = Factory.create(:user)
      @story.owned_by = @story.requested_by
      @project.users << @story.acting_user
      assert_difference 'ActionMailer::Base.deliveries.size' do
        @story.update_attribute :state, "#{action}ed"
      end
    end

    test "#{action}ing a story sends no email if acting user is not set" do
      @story.acting_user = nil
      @story.owned_by = @story.requested_by
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        @story.update_attribute :state, "#{action}ed"
      end
    end

    test "#{action}ing a story sends no email if owned_by is not set" do
      @story.acting_user = Factory.create(:user)
      @story.owned_by = nil
      @project.users << @story.acting_user
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        @story.update_attribute :state, "#{action}ed"
      end
    end

    test "#{action}ing a story sends no email if owned_by is acting user" do
      @story.acting_user = Factory.create(:user)
      @project.users << @story.acting_user
      @story.owned_by = @story.acting_user
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        @story.update_attribute :state, "#{action}ed"
      end
    end

  end
end
