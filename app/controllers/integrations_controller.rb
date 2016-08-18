class IntegrationsController < ApplicationController
  authorize_resource

  respond_to :html, :json

  def index
    @project = current_user.projects.friendly.find(params[:project_id])
    @integrations = @project.integrations
    @integration = Integration.new
    respond_with(@integrations)
  end

  def create
    @project = current_user.projects.friendly.find(params[:project_id])
    @integrations = @project.integrations
    @integration = @integrations.build(kind: params[:integration][:kind]).tap do |i|
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
    @project = current_user.projects.friendly.find(params[:project_id])
    @integration = @project.integrations.find(params[:id])
    @project.integrations.delete(@integration)
    redirect_to project_integrations_url(@project)
  end

end

