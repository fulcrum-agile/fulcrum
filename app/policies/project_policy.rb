class ProjectPolicy < ApplicationPolicy
  def show?
    is_admin? || current_user.projects.find_by_id(record.id)
  end

  def reports?
    index? || is_project_member?
  end

  def archived?
    update?
  end

  def import?
    update?
  end

  def import_upload?
    import?
  end

  class Scope < Scope
    def resolve
      if is_admin?
        current_team.projects
      else
        current_user.projects
      end
    end
  end
end
