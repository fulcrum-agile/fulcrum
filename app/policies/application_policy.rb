class ApplicationPolicy
  module CheckRoles
    protected

    def is_admin?
      context.current_user.is_admin?
    end

    def is_project_member?
      context.current_project && context.current_project.users.find_by_id(context.current_user.id)
    end

    def is_story_member?
      context.current_story && context.current_story.project.users.find_by_id(context.current_user.id)
    end
  end
  include CheckRoles

  attr_reader :context, :record

  def initialize(context, record)
    raise Pundit::NotAuthorizedError, "Must be signed in." unless context.current_user
    @context = context
    @record  = record
  end

  def manage?
    create? && update? && destroy?
  end

  def index?
    is_admin?
  end

  def show?
    index?
  end

  def create?
    is_admin?
  end

  def new?
    create?
  end

  def update?
    create?
  end

  def edit?
    update?
  end

  def destroy?
    create?
  end

  def scope
    Pundit.policy_scope!(context, record.class)
  end

  class Scope
    include CheckRoles
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @scope   = scope
    end

    def resolve
      scope
    end
  end
end
