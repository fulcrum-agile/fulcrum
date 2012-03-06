class ChangesetsController < ApplicationController
  respond_to :json

  def index
    @project = current_user.projects.find(params[:project_id])
    scope = @project.changesets.scoped
    scope = scope.where('id <= ?', params[:to]) if params[:to]
    scope = scope.where('id > ?', params[:from]) if params[:from]
    @changesets = scope
    respond_with @changesets
  end
end
