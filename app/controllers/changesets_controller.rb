class ChangesetsController < ApplicationController
  def index
    @project = current_user.projects.find(params[:project_id])
    # FIXME extract method to model
    @changesets = @project.changesets
    @changesets.since(params[:from]) if params[:from]
    @changesets.until(params[:to]) if params[:to]
    render :json => @changesets
  end
end
