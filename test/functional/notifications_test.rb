require 'test_helper'

class NotificationsTest < ActionMailer::TestCase

  # Needed for url helpers
  include Rails.application.routes.url_helpers
  
  def default_url_options
    Rails.application.config.action_mailer.default_url_options
  end

  test "delivered" do
    requester = FactoryGirl.create(:user, :name => "Requester")
    deliverer = FactoryGirl.create(:user, :name => "Deliverer")
    project = FactoryGirl.create(:project, :users => [requester, deliverer])
    story = FactoryGirl.create(:story, :project => project,
                            :requested_by => requester)

    mail = Notifications.delivered(story, deliverer)
    assert_equal "[Test Project] Your story 'Test story' has been delivered for acceptance.", mail.subject
    assert_equal [requester.email], mail.to
    assert_equal [deliverer.email], mail.from
    assert_match "Deliverer has delivered your story 'Test story'.", mail.body.encoded
    assert_match "You can now review the story, and either accept or reject it.", mail.body.encoded
    assert_match project_url(project), mail.body.encoded
  end

  test "accepted" do
    owner = FactoryGirl.create(:user, :name => "Owner")
    accepter = FactoryGirl.create(:user, :name => "Accepter")
    requester = FactoryGirl.create(:user, :name => "Requester")
    project = FactoryGirl.create(:project, :users => [owner, accepter, requester])
    story = FactoryGirl.create(:story, :project => project,
                            :requested_by => requester, :owned_by => owner)

    mail = Notifications.accepted(story, accepter)
    assert_equal "[Test Project] Accepter ACCEPTED your story 'Test story'.", mail.subject
    assert_equal [owner.email], mail.to
    assert_equal [accepter.email], mail.from
    assert_match "Accepter has accepted the story 'Test story'.", mail.body.encoded
    assert_match project_url(project), mail.body.encoded
  end

  test "rejected" do
    owner = FactoryGirl.create(:user, :name => "Owner")
    rejecter = FactoryGirl.create(:user, :name => "Rejecter")
    requester = FactoryGirl.create(:user, :name => "Requester")
    project = FactoryGirl.create(:project, :users => [owner, rejecter, requester])
    story = FactoryGirl.create(:story, :project => project,
                            :requested_by => requester, :owned_by => owner)

    mail = Notifications.rejected(story, rejecter)
    assert_equal "[Test Project] Rejecter REJECTED your story 'Test story'.", mail.subject
    assert_equal [owner.email], mail.to
    assert_equal [rejecter.email], mail.from
    assert_match "Rejecter has rejected the story 'Test story'.", mail.body.encoded
    assert_match project_url(project), mail.body.encoded
  end
end
