class TeamPolicy < ApplicationPolicy
  def create?
    true
  end

  def update?
    is_admin?
  end

  def destroy?
    is_admin?
  end

  class Scope < Scope
    def resolve
      if is_root?
        Team
      elsif is_admin?
        Team.not_archived.where(id: current_team.id)
      else
        Team.none
      end
    end
  end
end
