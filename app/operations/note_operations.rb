module NoteOperations

  module MemberNotification
    def self.included(base)
      base.class_eval do
        delegate :user, :story, to: :model
      end
    end

    def notify_users
      return if user.nil?

      users_to_notify = (story.stakeholders_users + users_from_note).uniq
      users_to_notify.delete(user)

      if users_to_notify.any? && !story.suppress_notifications
        notifier = Notifications.new_note(model.id, users_to_notify.map(&:email))
        notifier.deliver if notifier
      end
    end

    def users_from_note
      usernames = UsernameParser.parse(model.note)
      return [] if usernames.empty?

      story.users.where(username: usernames)
    end
  end

  class Create < BaseOperations::Create
    include MemberNotification

    def after_save
      model.story.changesets.create!
      notify_users
    end
  end
end
