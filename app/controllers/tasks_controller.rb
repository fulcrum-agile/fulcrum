class TasksController < ApplicationController
  before_filter :set_project_and_story

  def create
    @task = policy_scope(Task).build(allowed_params)
    authorize @task
    if TaskOperations::Create.(@task, current_user)
      render json: @task
    else
      render json: @task, status: :unprocessable_entity
    end
  end

  def destroy
    @task = policy_scope(Task).find(params[:id])
    authorize @task
    @task.destroy

    head :ok
  end

  def update
    @task = policy_scope(Task).find(params[:id])
    authorize @task
    @task.update_attributes(allowed_params)

    head :ok
  end

  private

  def allowed_params
    params.require(:task).permit(:name, :done)
  end

  def set_project_and_story
    @project = policy_scope(Project).find(params[:project_id])
    @story   = policy_scope(Story).find(params[:story_id])
  end

end
