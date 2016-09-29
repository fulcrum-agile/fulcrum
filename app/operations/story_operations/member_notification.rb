module StoryOperations
  module MemberNotification
    def self.included(base)
      base.class_eval do
        attr_reader :users_to_notify
      end
    end

    def notify_users
      return unless can_notify_mentioned_users?

      notifier = Notifications.story_mention(model.id, users_to_notify.pluck(:email))
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
end
