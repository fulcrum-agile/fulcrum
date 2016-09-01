class ActivityPresenter < SimpleDelegator
  include Rails.application.routes.url_helpers

  attr_reader :activity

  IGNORED_FIELDS = %w(updated_at created_at owned_by_id owned_by_initials requested_by_id)

  def initialize(activity)
    @activity = activity
    super
  end

  def eql?(targer)
    target == self || activity.eql?(target)
  end

  def description
    clause = if action == 'destroy'
               "#{subject_destroyed_type} ##{subject_changes['id']}"
             else
               return nil if subject.nil?
               "#{noun} #{predicate}".strip
             end
    "#{user.name} #{past_tense action} #{clause}"
  end

  private

  def noun
    case subject_type
    when 'Project'
      "#{subject_type} '#{helpers.link_to subject.name, project_path(subject)}'"
    when 'Story'
      "#{subject_type} ##{subject_id} - '#{helpers.link_to subject.title, project_path(subject.try(:project_id)) + '#story-' + subject_id.to_s}'"
    when 'Note', 'Task'
      "#{subject_type} '#{(subject.try(:note) || subject.try(:name)).truncate(20)}' for Story '#{helpers.link_to subject.story.title, project_path(subject.story.project_id) + '#story-' + subject.story_id.to_s}'"
    end
  end

  def predicate
    return "" unless action == 'update'
    changes = subject_changes.keys.reject { |key| IGNORED_FIELDS.include?(key) }.map do |key|
      if key == 'documents_attributes' || key == :documents_attributes
        document_changes subject_changes[key]
      else
        if subject_changes[key].first.nil?
          "#{key} to '#{subject_changes[key].last}'"
        else
          "#{key} from '#{subject_changes[key].first}' to '#{subject_changes[key].last}'"
        end
      end
    end.join(", ")
    "changing " + changes
  end

  def past_tense(verb)
    verb + (verb.at(-1) == "e" ? "d" : "ed")
  end

  def document_changes(changes)
    old_documents     = changes.first || []
    new_documents     = changes.last  || []
    added_documents   = new_documents - old_documents
    deleted_documents = old_documents - new_documents

    tmp_changes = []
    tmp_changes << "by uploading '#{added_documents.join("', '")}'"  if added_documents.size   > 0
    tmp_changes << "by deleting '#{deleted_documents.join("', '")}'" if deleted_documents.size > 0
    "documents " + tmp_changes.join(" and ")
  end

  def helpers
    ApplicationController.helpers
  end
end
