class UserPolicy < ApplicationPolicy
  def index?
    is_admin? || is_project_member?
  end

  def show?
    is_admin? || (is_project_member? && context.current_project.users.find_by_id(record.id))
  end

  def create?
    is_admin? || is_himself?
  end

  def is_himself?
    context.current_user == record
  end

  class Scope < Scope
    def resolve
      if is_admin?
        if context.current_project
          context.current_project.users
        else
          # Admin::UsersController
          context.current_team.users.all
        end
      elsif is_project_member?
        context.current_project.users
      else
        User.none
      end
    end
  end
end
