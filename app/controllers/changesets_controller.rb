class ChangesetsController < ApplicationController
  def index
    @project = current_user.projects.find(params[:project_id])
    # FIXME extract method to model
    scope = @project.changesets.scoped
    scope = scope.where('id <= ?', params[:to]) if params[:to]
    scope = scope.where('id > ?', params[:from]) if params[:from]
    @changesets = scope
    render :json => @changesets
  end
end
