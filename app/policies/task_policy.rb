class TaskPolicy < ApplicationPolicy
  def show?
    context.current_story.tasks.find_by_id(record.id)
  end

  class Scope < Scope
    def resolve
      context.current_story.tasks
    end
  end
end
