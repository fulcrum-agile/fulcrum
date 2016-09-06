class StoryPolicy < ApplicationPolicy
  def index?
    is_admin? || is_project_member?
  end

  def show?
    is_admin? || is_project_member? && context.current_project.stories.find_by_id(record.id)
  end

  def create?
    is_admin? || is_project_member?
  end

  def update?
    is_admin? || is_project_member?
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
      if is_admin?
        context.current_project.stories
      else
        if is_project_member?
          context.current_project.stories
        else
          Story.none
        end
      end
    end
  end
end

