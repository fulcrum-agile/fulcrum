class ProjectsController < ApplicationController
  respond_to :html, :json

  def index
    @projects = current_user.projects
    respond_with @projects
  end

  def show
    @project = current_user.projects.find(params[:id])
    @story = @project.stories.build
    respond_with @project
  end

  def new
    @project = Project.new
    respond_with @project
  end

  def edit
    @project = current_user.projects.find(params[:id])
    @project.users.build
    respond_with @project
  end

  def create
    @project = current_user.projects.build(params[:project])
    @project.users << current_user
    @project.save
    respond_with @project
  end

  def update
    @project = current_user.projects.find(params[:id])
    @project.update_attributes(params[:project])
    respond_with @project
  end

  def destroy
    @project = current_user.projects.find(params[:id])
    @project.destroy
    respond_with(@project, :location => projects_url)
  end

  def users
    @project = current_user.projects.find(params[:id])
    @users = @project.users
    respond_with(@project)
  end
end
