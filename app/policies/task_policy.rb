class TaskPolicy < ApplicationPolicy
  def show?
    context.current_story.tasks.find(record)
  end

  def create?
    context.current_user.is_admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
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
      context.current_story.tasks
    end
  end
end
