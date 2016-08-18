class StoryObserver < ActiveRecord::Observer

  # Create a new changeset whenever the story is changed
  def after_save(story)
    if story.state_changed?
      notifier = nil
      unless story.project.suppress_notifications

        # Send a 'the story has been delivered' notification if the state has
        # changed to 'delivered'
        # FIXME Move to predicate on Story
        if story.state == 'started'
          notifier = Notifications.started(story, story.acting_user)
          if notifier && story.acting_user && story.requested_by && story.requested_by.email_delivery? && story.acting_user != story.requested_by
            notifier.deliver
          end
        end

        if story.state == 'delivered'
          notifier = Notifications.delivered(story, story.acting_user)
          if notifier && story.acting_user && story.requested_by && story.requested_by.email_delivery? && story.acting_user != story.requested_by
            notifier.deliver
          end
        end

        # Send 'story accepted' email if state changed to 'accepted'
        if story.state == 'accepted'
          notifier = Notifications.accepted(story, story.acting_user)
          if notifier && story.acting_user && story.owned_by && story.owned_by.email_acceptance? && story.owned_by != story.acting_user
            notifier.deliver
          end
        end

        # Send 'story rejected' email if state changed to 'rejected'
        if story.state == 'rejected'
          notifier = Notifications.rejected(story, story.acting_user)
          if notifier && story.acting_user && story.owned_by && story.owned_by.email_rejection? && story.owned_by != story.acting_user
            notifier.deliver
          end
        end

      end

      # FIXME move this code to some other service that concentrates both sending email and pushing integrations
      if notifier && story.project.integrations.count > 0
        IntegrationWorker.perform_async(story.project_id, notifier.subject)
      end

      # Set the project start date to today if the project start date is nil
      # and the state is changing to any state other than 'unstarted' or
      # 'unscheduled'
      # FIXME Make model method on Story
      if story.project && !story.project.start_date && !['unstarted', 'unscheduled'].include?(story.state)
        story.project.update_attribute :start_date, Date.today
      end
    end

    # If a story's 'accepted at' date is prior to the project start date,
    # the project start date should be moved back accordingly
    if story.accepted_at_changed? && story.accepted_at && story.accepted_at < story.project.start_date
      story.project.update_attribute :start_date, story.accepted_at
    end

  end

end
