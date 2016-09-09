class ProjectPolicy < ApplicationPolicy
  def show?
    is_admin? || current_user.projects.find_by_id(record.id)
  end

  def reports?
    is_admin? || is_project_member?
  end

  def archived?
    update?
  end

  def import?
    is_admin? && is_project_owner?
  end

  def import_upload?
    import?
  end

  def archive?
    import?
  end

  def unarchive?
    archive?
  end

  def destroy?
    archive?
  end

  def share?
    archive?
  end

  def unshare?
    share?
  end

  def transfer?
    share?
  end

  def ownership?
    share?
  end

  class Scope < Scope
    def resolve
      if is_admin?
        current_team.projects
      else
        current_user.projects.not_archived.where(id: current_team.projects.pluck(:id))
      end
    end
  end
end
