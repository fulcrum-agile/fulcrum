class UserContext < PunditContext
  attr_reader :current_project

  def initialize(current_user, current_project)
    @current_project = current_project
    super(current_user)
  end
end

