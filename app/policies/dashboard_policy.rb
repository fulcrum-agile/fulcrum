class DashboardPolicy < ApplicationPolicy
  def dashboard?
    true
  end

  def index?
    true
  end
end
