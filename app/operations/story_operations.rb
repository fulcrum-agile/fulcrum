require 'story_operations/member_notification'
require 'story_operations/state_change_notification'
require 'story_operations/legacy_fixes'

module StoryOperations

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
