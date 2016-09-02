class NotePolicy < ApplicationPolicy
  def show?
    context.current_story.notes.find(record)
  end

  def done?
    update?
  end

  def backlog?
    update?
  end

  def in_progress?
    update?
  end

  class Scope < Scope
    def resolve
      context.current_story.notes
    end
  end
end


