class UserPolicy < ApplicationPolicy
  def show?
    context.current_project.users.find(record)
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

  class Scope < Scope
    def resolve
      context.current_project.users
    end
  end
end

