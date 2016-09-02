class AdminUserPolicy < ApplicationPolicy
  def show?
    create?
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
  end
end
