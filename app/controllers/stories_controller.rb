class StoriesController < ApplicationController

  def update
    @project = current_user.projects.find(params[:project_id])
    @story = @project.stories.find(params[:id])
    @story.update_attributes(params[:story])
    redirect_to project_url(@project)
  end

  def done
    @project = current_user.projects.find(params[:project_id])
    @stories = @project.stories.done
    render :json => @stories, :methods => [:events, :estimable, :estimated]
  end
  def backlog
    @project = current_user.projects.find(params[:project_id])
    @stories = @project.stories.backlog
    render :json => @stories, :methods => [:events, :estimable, :estimated]
  end
  def in_progress
    @project = current_user.projects.find(params[:project_id])
    @stories = @project.stories.in_progress
    render :json => @stories, :methods => [:events, :estimable, :estimated]
  end

  def create
    @project = current_user.projects.find(params[:project_id])
    @story = @project.stories.build(params[:story])
    @story.save!
    redirect_to project_url(@project)
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
end
