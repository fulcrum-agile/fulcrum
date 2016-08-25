module StoryOperations

  module MemberNotification
    def self.included(base)
      base.class_eval do
        attr_reader :users_to_notify
      end
    end

    def notify_users
      return unless can_notify_mentioned_users?

      notifier = Notifications.story_mention(model, users_to_notify)
      notifier.deliver if notifier
    end

    def users_from_story
      usernames = UsernameParser.parse(model.description)
      return [] if usernames.empty?

      @users_to_notify ||= model.users.where(username: usernames).all
    end

    def can_notify_mentioned_users?
      model.description.present? && users_from_story.any? &&
        !model.suppress_notifications
    end
  end

  module StateChangeNotification
    def notify_state_changed
      return unless can_notify_state_changed?

      notifier = Notifications.public_send(model.state.to_sym, model, model.acting_user)
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
        return false unless actor.email_delivery?
      when 'accepted'
        actor = model.owned_by
        return false unless actor.email_acceptance?
      when 'rejected'
        actor = model.owned_by
        return false unless actor.email_rejection?
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

  module LegacyFixes
    def fix_project_start_date
      return unless model.state_changed?
      # Set the project start date to today if the project start date is nil
      # and the state is changing to any state other than 'unstarted' or
      # 'unscheduled'
      # FIXME Make model method on Story
      if model.project && !model.project.start_date && !['unstarted', 'unscheduled'].include?(model.state)
        model.project.start_date = Date.today
      end
    end

    def fix_story_accepted_at
      # If a story's 'accepted at' date is prior to the project start date,
      # the project start date should be moved back accordingly
      if model.accepted_at_changed? && model.accepted_at && model.accepted_at < model.project.start_date
        model.project.start_date = model.accepted_at
      end
    end

    def apply_fixes
      fix_project_start_date
      fix_story_accepted_at
      model.project.save! if model.project.start_date_changed?
    end
  end


  class Create < BaseOperations::Create
    include MemberNotification

    def after_save
      model.changesets.create!

      notify_users
    end
  end

  class Update < BaseOperations::Update
    include MemberNotification
    include StateChangeNotification
    include LegacyFixes

    def after_save
      model.changesets.create!

      apply_fixes

      notify_state_changed
      notify_users
    end
  end

  class Destroy < BaseOperations::Destroy
  end

end
