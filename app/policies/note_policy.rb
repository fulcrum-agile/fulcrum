class NotePolicy < StoryPolicy
  def show?
    current_story.notes.find_by_id(record.id)
  end

  class Scope < Scope
    def resolve
      if is_admin?
        current_story.notes
      else
        if is_story_member?
          current_story.notes
        else
          Note.none
        end
      end
    end
  end
end
