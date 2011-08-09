class StoryObserver < ActiveRecord::Observer
  # Create a new changeset whenever the story is changed
  def after_save(story)
    story.changesets.create!

    # Send a 'the story has been delivered' notification if the state has
    # changed to 'delivered'
    if story.state_changed? && story.state == 'delivered' && story.acting_user && story.requested_by && story.acting_user != story.requested_by
      notifier = Notifications.delivered(story, story.acting_user)
      notifier.deliver if notifier
    end

    # Send 'story accepted' email if state changed to 'accepted'
    if story.state_changed? && story.state == 'accepted' && story.acting_user && story.owned_by && story.owned_by != story.acting_user
      notifier = Notifications.accepted(story, story.acting_user)
      notifier.deliver if notifier
    end

    # Send 'story accepted' email if state changed to 'accepted'
    if story.state_changed? && story.state == 'rejected' && story.acting_user && story.owned_by && story.owned_by != story.acting_user
      notifier = Notifications.rejected(story, story.acting_user)
      notifier.deliver if notifier
    end

    # Set the project start date to today if the project start date is nil
    # and the state is changing to any state other than 'unstarted' or
    # 'unscheduled'
    if story.state_changed? && story.project && !story.project.start_date && !['unstarted', 'unscheduled'].include?(story.state)
      story.project.update_attribute :start_date, Date.today
    end
  end
end
