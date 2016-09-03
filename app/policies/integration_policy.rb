class IntegrationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if is_admin?
        context.current_project.integrations
      else
        Integration.none
      end
    end
  end
end
