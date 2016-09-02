class UserPolicy < ApplicationPolicy
  def show?
    context.current_project.users.find(record)
  end

  class Scope < Scope
    def resolve
      context.current_project.users
    end
  end
end
