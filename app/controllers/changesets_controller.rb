class ChangesetsController < ApplicationController
  def index
    @project = current_user.projects.find(params[:project_id])
    # FIXME extract method to model
    @changesets = @project.changesets
    @changesets = @changesets.since(params[:from]) if allowed_params.has_key?(:from)
    @changesets = @changesets.until(params[:to]) if allowed_params.has_key?(:to)
    render :json => @changesets
  end

  def allowed_params
    params.permit(:from,:to,:project_id)
  end
end