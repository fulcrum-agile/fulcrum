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

    def before_save
      model.documents_attributes_was = model.documents_attributes
    end

    def after_save
      new_documents = model.documents_attributes
      if new_documents != model.documents_attributes_was
        model.instance_variable_get('@changed_attributes')[:documents_attributes] = model.documents_attributes_was
      end
      model.changesets.create!

      apply_fixes

      notify_state_changed
      notify_users
    end
  end

  class Destroy < BaseOperations::Destroy
  end

end
