class Admin::UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :destroy]

  # GET /admin/users
  def index
    @users = policy_scope(User)
  end

  # GET /admin/users/1/edit
  def edit
  end

  # PATCH/PUT /admin/users/1
  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /admin/users/1
  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: 'User was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = policy_scope(User).includes(:projects).find(params[:id])
      authorize @user
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.fetch(:user,{}).permit(:email, :name, :initials)
    end

end
