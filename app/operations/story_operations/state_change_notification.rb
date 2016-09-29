module StoryOperations
  module StateChangeNotification
    def notify_state_changed
      return unless can_notify_state_changed?

      notifier = Notifications.public_send(model.state.to_sym, model.id, model.acting_user.id)
      notifier.deliver if notifier
      IntegrationWorker.perform_async(model.project.id, integration_message)
    end

    def can_notify_state_changed?
      return false unless model.state_changed?
      return false if model.suppress_notifications
      return false unless model.acting_user

      actor = nil
      case model.state
      when 'started', 'delivered'
        actor = model.requested_by
        return false unless actor && actor.email_delivery?
      when 'accepted'
        actor = model.owned_by
        return false unless actor && actor.email_acceptance?
      when 'rejected'
        actor = model.owned_by
        return false unless actor && actor.email_rejection?
      else
        return false
      end

      model.acting_user != actor
    end

    def integration_message
      story_link = "#{model.base_uri}#story-#{model.id}"

      case model.state
      when 'started'
        "[#{model.project.name}] The story ['#{model.title}'](#{story_link}) has been started."
      when 'delivered'
        "[#{model.project.name}] The story ['#{model.title}'](#{story_link}) has been delivered for acceptance."
      when 'accepted'
        "[#{model.project.name}] #{model.acting_user.name} ACCEPTED your story ['#{model.title}'](#{story_link})."
      when 'rejected'
        "[#{model.project.name}] #{model.acting_user.name} REJECTED your story ['#{model.title}'](#{story_link})."
      end
    end
  end
end
