class UsersController < ApplicationController
  before_filter :set_project

  respond_to :html, :json

  def index
    @user = policy_scope(User).build
    respond_with(@project.users)
  end

  def create
    @user = User.find_or_create_by(email: params[:user][:email]) do |u|
      # Set to true if the user was not found
      u.was_created = true
      u.name = params[:user][:name]
      u.initials = params[:user][:initials]
      u.username = params[:user][:username]
    end
    authorize @user

    if @user.new_record? && !@user.save
      render 'index'
      return
    end

    if policy_scope(User).include?(@user)
      flash[:alert] = "#{@user.email} is already a member of this project"
    else
      policy_scope(User) << @user
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
    @user = policy_scope(User).find(params[:id])
    authorize @user
    policy_scope(User).delete(@user)
    flash[:notice] = "#{@user.email} was removed from this project"

    respond_to do |format|
      format.js { render :refresh_user_list }
      format.html { redirect_to project_users_url(@project) }
    end
  end

  private

  def set_project
    @project = current_user.projects.friendly.find(params[:project_id])
  end

end
