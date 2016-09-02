class UserPolicy < ApplicationPolicy
  def show?
    context.current_project.users.find_by_id(record.id)
  end

  class Scope < Scope
    def resolve
      context.current_project.users
    end
  end
end
