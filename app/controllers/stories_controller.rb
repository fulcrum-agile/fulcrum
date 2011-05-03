class StoriesController < ApplicationController

  def index
    @project = current_user.projects.find(params[:project_id])
    @stories = @project.stories
    render :json => @stories
  end

  def show
    @project = current_user.projects.find(params[:project_id])
    @story = @project.stories.find(params[:id])
    render :json => @story
  end

  def update
    @project = current_user.projects.find(params[:project_id])
    @story = @project.stories.find(params[:id])
    respond_to do |format|
      if @story.update_attributes(filter_story_params)
        format.html { redirect_to project_url(@project) }
        format.js   { render :json => @story }
      else
        format.html { render :action => 'edit' }
        format.js   { render :json => @story, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @project = current_user.projects.find(params[:project_id])
    @story = @project.stories.find(params[:id])
    @story.destroy
    head :ok
  end

  def done
    @project = current_user.projects.find(params[:project_id])
    @stories = @project.stories.done
    render :json => @stories
  end
  def backlog
    @project = current_user.projects.find(params[:project_id])
    @stories = @project.stories.backlog
    render :json => @stories
  end
  def in_progress
    @project = current_user.projects.find(params[:project_id])
    @stories = @project.stories.in_progress
    render :json => @stories
  end

  def create
    @project = current_user.projects.find(params[:project_id])
    @story = @project.stories.build(filter_story_params)
    @story.requested_by_id = current_user.id unless @story.requested_by_id
    @story.save!
    respond_to do |format|
      format.html { redirect_to project_url(@project) }
      format.js   { render :json => @story }
    end
  end

  def start
    state_change(:start!)
  end

  def finish
    state_change(:finish!)
  end

  def deliver
    state_change(:deliver!)
  end

  def accept
    state_change(:accept!)
  end

  def reject
    state_change(:reject!)
  end

  private
  def state_change(transition)
    @project = current_user.projects.find(params[:project_id])

    @story = @project.stories.find(params[:id])
    @story.send(transition)

    redirect_to project_url(@project)
  end

  # Removes all unwanted keys from the params hash passed for Backbone
  def filter_story_params
    allowed = [
      :title, :description, :estimate, :story_type, :state, :requested_by_id,
      :owned_by_id, :position
    ]
    filtered = {}
    params[:story].each do |key, value|
      filtered[key.to_sym] = value if allowed.include?(key.to_sym)
    end
    filtered
  end
end
