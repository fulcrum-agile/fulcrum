class IntegrationsController < ApplicationController
  before_action :set_project

  respond_to :html, :json

  def index
    @integration = policy_scope(Integration).build
    respond_with(@project.integrations)
  end

  def create
    @integration = policy_scope(Integration).build(kind: params[:integration][:kind])
    authorize @integration
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
    @integration = policy_scope(Integration).find(params[:id])
    authorize @integration
    @project.integrations.delete(@integration)
    redirect_to project_integrations_url(@project)
  end

  private

  def set_project
    @project = policy_scope(Project).friendly.find(params[:project_id])
  end

end

