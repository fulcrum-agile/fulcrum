class AdminUserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if is_admin?
        User
      else
        User.none
      end
    end
  end
end
