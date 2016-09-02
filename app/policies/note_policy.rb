class NotePolicy < ApplicationPolicy
  def show?
    context.current_story.notes.find_by_id(record.id)
  end

  class Scope < Scope
    def resolve
      context.current_story.notes
    end
  end
end
