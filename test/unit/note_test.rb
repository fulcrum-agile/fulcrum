require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  def setup
    @user = Factory.create(:user)
    @project = Factory.create(:project, :users => [@user])
    @story = Factory.create(:story, :project => @project,
                            :requested_by => @user)
    @note = Factory.create(:note, :story => @story, :user => @user)
  end

  test "cannot save without a body" do
    @note.note = ''
    assert !@note.valid?
  end

  test "creating a note creates a changeset" do
    assert_difference ['Changeset.count', '@story.changesets.count'] do
      Factory.create(:note, :story => @story, :user => @user)
    end
  end

  test "creating a note sends a notification" do
    user = Factory.create(:user)
    @project.users << user
    @story.requested_by = user
    assert_difference 'ActionMailer::Base.deliveries.count' do
      Factory.create(:note, :story => @story, :user => @user)
    end
    assert_equal [user.email], ActionMailer::Base.deliveries.first.to
    assert_equal [@user.email], ActionMailer::Base.deliveries.first.from

    @project.suppress_notifications = true
    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      Factory.create(:note, :story => @story, :user => @user)
    end
  end

  test "creating a note does not send a notification for the current user" do
    assert_equal [@user], @story.notify_users
    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      Factory.create(:note, :story => @story, :user => @user)
    end
  end

  test "returns JSON" do
    attrs = [
      "id", "created_at", "updated_at", "user_id", "story_id", "note", "errors"
    ]
    assert_returns_json attrs, @note
  end
end
