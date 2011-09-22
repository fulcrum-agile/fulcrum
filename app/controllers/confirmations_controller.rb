class ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    
    if resource.valid? && resource.errors.empty?
      set_flash_message :notice, :confirmed
      redirect_to edit_user_password_path(:reset_password_token => resource.reset_password_token)
    else
      set_flash_message :notice, :invalid_token
      render 'devise/confirmations/new'
    end
  end

  def new
    self.resource = User.new
    render 'devise/confirmations/new'
  end

end