class TasksController < ApplicationController
  before_filter :find_current_story

  def create
    if @task = TaskCreationService.create(@story.tasks.build(allowed_params))
      render json: @task
    else
      render json: @task, status: :unprocessable_entity
    end
  end

  def destroy
    @task = @story.tasks.find(params[:id])
    @task.destroy

    head :ok
  end

  private

  def find_current_story
    @project = current_user.projects.find(params[:project_id])
    @story = @project.stories.find(params[:story_id])
  end

  def allowed_params
    params.require(:task).permit(:name, :done)
  end
end
