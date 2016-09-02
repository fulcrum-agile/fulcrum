class ProjectPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    context.current_user.projects.find(record)
  end

  def reports?
    index?
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
