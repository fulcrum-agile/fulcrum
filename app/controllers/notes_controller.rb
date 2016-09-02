class NotesController < ApplicationController
  before_action :set_project_and_story

  def index
    @notes = policy_scope(Note)
    render json: @notes
  end

  def show
    @note = policy_scope(Note).find(params[:id])
    authorize @note
    render json: @note
  end

  def destroy
    @note = policy_scope(Note).find(params[:id])
    authorize @note
    @note.destroy
    head :ok
  end

  def create
    @note = policy_scope(Note).build(allowed_params)
    authorize @note
    @note.user = current_user
    if @note = NoteOperations::Create.(@note, current_user)
      render json: @note
    else
      render json: @note, status: :unprocessable_entity
    end
  end

  protected

  def allowed_params
    params.fetch(:note).permit(:note, :documents)
  end

  def set_project_and_story
    @project = current_user.projects.find(params[:project_id])
    @story = @project.stories.find(params[:story_id])
  end

  def pundit_user
    NoteContext.new(current_user, @story)
  end

end
