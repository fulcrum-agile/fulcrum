class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can :manage, Project, :id => user.project_ids
  end
end
