class IntegrationsController < ApplicationController
  authorize_resource
  before_action :load_project

  respond_to :html, :json

  def index
    @integration = Integration.new
    respond_with(@project.integrations)
  end

  def create
    @integration = @project.integrations.build(kind: params[:integration][:kind]).tap do |i|
      i.data = JSON.parse params[:integration][:data]
    end

    if @project.integrations.find_by(kind: @integration.kind)
      flash[:alert] = "#{@integration.kind} is already configured for this project"
    else
      if @integration.save
        flash[:notice] = "#{@integration.kind} was added to this project"
      else
        render 'index'
        return
      end
    end

    redirect_to project_integrations_url(@project)
  end

  def destroy
    @integration = @project.integrations.find(params[:id])
    @project.integrations.delete(@integration)
    redirect_to project_integrations_url(@project)
  end

  private

  def load_project
    @project = current_user.projects.friendly.find(params[:project_id])
  end

end

