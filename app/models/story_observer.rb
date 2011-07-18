class StoryObserver < ActiveRecord::Observer
  # Create a new changeset whenever the story is changed
  def after_save(story)
    story.changesets.create!

    # Send a 'the story has been delivered' notification if the state has
    # changed to 'delivered'
    if story.changed? && story.state == 'delivered' && story.acting_user && story.acting_user != story.requested_by
      notifier = Notifications.delivered(story, story.acting_user)
      notifier.deliver if notifier
    end
  end
end
