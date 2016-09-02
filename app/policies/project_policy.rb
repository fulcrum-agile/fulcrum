class ProjectPolicy < ApplicationPolicy
  def show?
    context.current_user.projects.find(record)
  end

  def create?
    context.current_user.is_admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
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
      context.current_user.projects
    end
  end
end
