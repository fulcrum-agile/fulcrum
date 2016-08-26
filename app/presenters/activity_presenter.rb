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
      if subject_changes[key].first.nil?
        "#{key} to '#{subject_changes[key].last}' "
      else
        "#{key} from '#{subject_changes[key].first}' to '#{subject_changes[key].last}' "
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
