class IntegrationsController < ApplicationController
  before_action :load_project

  respond_to :html, :json

  def index
    @integration = Integration.new
    respond_with(@project.integrations)
  end

  def create
    @integration = @project.integrations.build(kind: params[:integration][:kind])
    @integration.data = JSON.parse params[:integration][:data]

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

  rescue JSON::ParserError, TypeError
    flash.now[:error] = "Insert a valid JSON into 'Data' field"
    render 'index'
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

