class ApplicationPolicy
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
    context.current_user.is_admin?
  end

  def show?
    index?
  end

  def create?
    context.current_user.is_admin?
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
