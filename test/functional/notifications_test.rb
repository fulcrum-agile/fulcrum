require 'test_helper'

class NotificationsTest < ActionMailer::TestCase

  # Needed for url helpers
  include Rails.application.routes.url_helpers
  
  def default_url_options
    Rails.application.config.action_mailer.default_url_options
  end

  test "delivered" do
    requester = Factory.create(:user, :name => "Requester")
    deliverer = Factory.create(:user, :name => "Deliverer")
    project = Factory.create(:project, :users => [requester, deliverer])
    story = Factory.create(:story, :project => project,
                            :requested_by => requester)

    mail = Notifications.delivered(story, deliverer)
    assert_equal "[Test Project] Your story 'Test story' has been delivered for acceptance.", mail.subject
    assert_equal [requester.email], mail.to
    assert_equal [deliverer.email], mail.from
    assert_match "Deliverer has delivered your story 'Test story'.", mail.body.encoded
    assert_match "You can now review the story, and either accept or reject it.", mail.body.encoded
    assert_match project_url(project), mail.body.encoded
  end
end
