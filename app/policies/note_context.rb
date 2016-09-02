class NoteContext < PunditContext
  attr_reader :current_story

  def initialize(current_user, current_story)
    @current_story = current_story
    super(current_user)
  end
end
