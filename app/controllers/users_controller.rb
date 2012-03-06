class UsersController < ApplicationController

  respond_to :html, :json

  def index
    @project = current_user.projects.find(params[:project_id])
    @users = @project.users
    @user = User.new
    respond_with(@users)
  end

  def create
    @project = current_user.projects.find(params[:project_id])
    @users = @project.users
    @user = User.find_or_create_by_email(params[:user][:email]) do |u|
      # Set to true if the user was not found
      u.was_created = true
      u.name = params[:user][:name]
      u.initials = params[:user][:initials]
    end

    if @user.new_record? && !@user.save
      render 'index'
      return
    end

    if @project.users.include?(@user)
      flash[:alert] = I18n.t( 'create.existing', :email => @user.email,
                              :scope => [:flash, :users, :actions])
    else
      @project.users << @user
      if @user.was_created
        flash[:notice] = I18n.t( 'create.invited', :email => @user.email,
                                  :scope => [:flash, :users, :actions])
      else
        flash[:notice] = I18n.t( 'create.added', :email => @user.email,
                                  :scope => [:flash, :users, :actions])
      end
    end

    redirect_to project_users_url(@project)
  end

  def destroy
    @project = current_user.projects.find(params[:project_id])
    @user = @project.users.find(params[:id])
    @project.users.delete(@user)
    redirect_to project_users_url(@project)
  end

end
