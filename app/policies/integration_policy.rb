class IntegrationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      context.current_project.integrations
    end
  end
end
