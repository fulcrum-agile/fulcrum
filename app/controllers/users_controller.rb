class UsersController < ApplicationController
  authorize_resource

  respond_to :html, :json

  def index
    @project = current_user.projects.friendly.find(params[:project_id])
    @user = User.new
    respond_with(@project.users)
  end

  def create
    @project = current_user.projects.friendly.find(params[:project_id])
    @user = User.find_or_create_by(email: params[:user][:email]) do |u|
      # Set to true if the user was not found
      u.was_created = true
      u.name = params[:user][:name]
      u.initials = params[:user][:initials]
      u.username = params[:user][:username]
    end

    if @user.new_record? && !@user.save
      render 'index'
      return
    end

    if @project.users.include?(@user)
      flash[:alert] = "#{@user.email} is already a member of this project"
    else
      @project.users << @user
      if @user.was_created
        flash[:notice] = "#{@user.email} was sent an invite to join this project"
      else
        flash[:notice] = "#{@user.email} was added to this project"
      end
    end

    respond_to do |format|
      format.js { render :refresh_user_list }
      format.html { redirect_to project_users_url(@project) }
    end
  end

  def destroy
    @project = current_user.projects.friendly.find(params[:project_id])
    @user = @project.users.find(params[:id])
    @project.users.delete(@user)
    flash[:notice] = "#{@user.email} was removed from this project"

    respond_to do |format|
      format.js { render :refresh_user_list }
      format.html { redirect_to project_users_url(@project) }
    end
  end

end
