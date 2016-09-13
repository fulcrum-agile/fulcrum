class ProjectPolicy < ApplicationPolicy
  def show?
    is_admin? || current_user.projects.find_by_id(record.id)
  end

  def reports?
    is_admin? || is_project_member?
  end

  def import?
    is_admin? && is_project_owner?
  end

  alias_method :archived?,      :update?
  alias_method :import_upload?, :import?
  alias_method :archive?,       :import?
  alias_method :unarchive?,     :archive?
  alias_method :destroy?,       :archive?
  alias_method :share?,         :archive?
  alias_method :unshare?,       :share?
  alias_method :transfer?,      :share?
  alias_method :ownership?,     :share?

  class Scope < Scope
    def resolve
      if is_root?
        Project.all
      elsif is_admin?
        current_team.projects
      else
        current_user.projects.not_archived.where(id: current_team.projects.pluck(:id))
      end
    end
  end
end
