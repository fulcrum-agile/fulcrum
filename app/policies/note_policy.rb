class NotePolicy < ApplicationPolicy
  def show?
    context.current_story.notes.find(record)
  end

  class Scope < Scope
    def resolve
      context.current_story.notes
    end
  end
end
