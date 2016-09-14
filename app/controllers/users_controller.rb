class UsersController < ApplicationController
  before_filter :set_project

  respond_to :html, :json

  def index
    @user = User.new
    respond_with(@project.users)
  end

  def create
    @user = User.find_or_create_by(email: allowed_params[:email]) do |u|
      # Set to true if the user was not found
      u.was_created = true
      u.name        = allowed_params[:name]
      u.initials    = allowed_params[:initials]
      u.username    = allowed_params[:username]
    end
    authorize @user

    if @user.new_record? && !@user.save
      render 'index'
      return
    end

    if policy_scope(User).include?(@user)
      flash[:alert] = I18n.t('is already a member of this project', scope: 'users', email: @user.email)
    else
      policy_scope(User) << @user
      @user.teams << current_team unless @user.teams.include?(current_team)
      if @user.was_created
        flash[:notice] = I18n.t('was sent an invite to join this project', scope: 'users', email: @user.email)
      else
        flash[:notice] = I18n.t('was added to this project', scope: 'users', email: @user.email)
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

  def allowed_params
    params.require(:user).permit(:email, :name, :initials, :username, :locale, :time_zone)
  end

  def set_project
    @project = policy_scope(Project).friendly.find(params[:project_id])
  end

end
