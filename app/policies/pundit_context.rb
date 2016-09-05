class PunditContext
  attr_reader :current_team, :current_user, :current_story, :current_project

  def initialize(current_team, current_user, options = {})
    @current_team    = current_team
    @current_user    = current_user
    @current_project = options.delete(:current_project)
    @current_story   = options.delete(:current_story)
  end
end
