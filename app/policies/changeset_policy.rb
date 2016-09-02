class ChangesetPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      context.current_user.projects
    end
  end
end
