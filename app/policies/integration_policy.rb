class IntegrationPolicy < ApplicationPolicy
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
      context.current_project.integrations
    end
  end
end
