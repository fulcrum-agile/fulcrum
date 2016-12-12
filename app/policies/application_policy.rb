require 'active_support/core_ext/module/delegation'

class ApplicationPolicy
  module CheckRoles
    def self.included(base)
      base.class_eval do
        delegate :current_user, :current_team, :current_project, :current_story,
          to: :context
      end
    end

    protected

    def is_root?
      # this user can do anothing, it goes in AdminUser instead of User and bypasses everything
      context.active_admin
    end

    def is_admin?
      is_root? || ( current_team && current_team.is_admin?(current_user) )
    end

    def is_project_owner?
      is_root? || ( current_project && current_team.owns?(current_project) )
    end

    def is_project_member?
      is_root? || ( current_project && current_project.users.find_by_id(current_user.id) )
    end

    def is_story_member?
      is_root? || ( current_story && current_story.project.users.find_by_id(current_user.id) )
    end

    def is_team_member?
      is_root? || ( current_team && current_team.users.find_by_id(current_user.id) )
    end

  end
  include CheckRoles

  attr_reader :context, :record

  def initialize(context, record)
    if context.is_a?(AdminUser)
      context = PunditContext.new(nil, context, { active_admin: true })
    end
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
      if context.is_a?(AdminUser)
        context = PunditContext.new(nil, context, { active_admin: true })
      end
      @context = context
      @scope   = scope
    end

    def resolve
      scope
    end
  end
end
