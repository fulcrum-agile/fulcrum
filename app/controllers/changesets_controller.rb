class ChangesetsController < ApplicationController

  def index
    @project = policy_scope(Changeset).find(allowed_params[:project_id])
    # FIXME extract method to model
    @changesets = @project.changesets
    @changesets = @changesets.since(allowed_params[:from]) if allowed_params.has_key?(:from)
    @changesets = @changesets.until(allowed_params[:to]) if allowed_params.has_key?(:to)
    render json: @changesets
  end

  protected

  def allowed_params
    params.permit(:from,:to,:project_id)
  end
end
