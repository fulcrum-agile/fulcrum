class ActivityPresenter < SimpleDelegator
  include Rails.application.routes.url_helpers
  attr_reader :activity

  def initialize(activity)
    @activity = activity
    __setobj__(activity)
  end

  def eql?(targer)
    target == self || activity.eql?(target)
  end

  def description
    if action == 'destroy'
      object = "#{subject_destroyed_type} ##{subject_changes['id']}"
    else
      return nil if subject.nil?
      object = noun + update_changes
    end
    "#{user.name} #{past_tense action} #{object}"
  end

  private

  def noun
    case subject_type
    when 'Project'
      "#{subject_type} ##{subject_id} - '#{helpers.link_to subject.name, project_path(subject)}'"
    when 'Story'
      "#{subject_type} ##{subject_id} - '#{helpers.link_to subject.title, project_path(subject.try(:project_id)) + '#story-' + subject_id.to_s}'"
    when 'Note', 'Task'
      "#{subject_type} ##{subject_id} of Story '#{helpers.link_to subject.story.title, project_path(subject.story.project_id) + '#story-' + subject.story_id.to_s}'"
    end
  end

  def update_changes
    return "" unless action == 'update'
    changes = subject_changes.keys.reject { |key| %w(updated_at created_at).include?(key) }.map do |key|
      if key == 'documents_attributes'
        old_documents     = subject_changes[key].first || []
        new_documents     = subject_changes[key].last  || []
        added_documents   = new_documents - old_documents
        deleted_documents = old_documents - new_documents

        tmp_changes = []
        tmp_changes << "by uploading '#{added_documents.join("', '")}'"  if added_documents.size   > 0
        tmp_changes << "by deleting '#{deleted_documents.join("', '")}'" if deleted_documents.size > 0
        "documents " + tmp_changes.join(" and ")
      else
        if subject_changes[key].first.nil?
          "#{key} to '#{subject_changes[key].last}' "
        else
          "#{key} from '#{subject_changes[key].first}' to '#{subject_changes[key].last}' "
        end
      end
    end.join(", ")
    " changed " + changes
  end

  def past_tense(verb)
    if verb.at(-1) == "e"
      verb + "d"
    else
      verb + "ed"
    end
  end

  def helpers
    ApplicationController.helpers
  end
end
