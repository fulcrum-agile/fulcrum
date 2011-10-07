class ChangesetsController < ApplicationController
  skip_before_filter :authenticate_user!, :only => [:index]
  before_filter :permit_public_project, :only => [:index]

  def index
    scope = @project.changesets.scoped
    scope = scope.where('id <= ?', params[:to]) if params[:to]
    scope = scope.where('id > ?', params[:from]) if params[:from]
    @changesets = scope
    render :json => @changesets
  end
end
