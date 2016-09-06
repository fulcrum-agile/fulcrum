require 'active_support/core_ext/module/delegation'

class ApplicationPolicy
  module CheckRoles
    def self.included(base)
      base.class_eval do
        delegate :current_user, to: :context
        delegate :current_team, to: :context
        delegate :current_project, to: :context
        delegate :current_story, to: :context
      end
    end

    protected

    def is_admin?
      current_team.is_admin?(current_user)
    end

    def is_project_member?
      current_project && current_project.users.find_by_id(current_user.id)
    end

    def is_story_member?
      current_story.project.users.find_by_id(current_user.id)
    end

    def is_team_member?
      current_team.users.find_by_id(current_user.id)
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
