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
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
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
