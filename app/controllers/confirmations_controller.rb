class ConfirmationsController < Devise::ConfirmationsController

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.valid? && resource.errors.empty?
      set_flash_message :notice, :confirmed
      reset_token = resource.set_reset_password_token
      redirect_to edit_user_password_path(:reset_password_token => reset_token)
    else
      set_flash_message :notice, :invalid_token
      redirect_to new_user_confirmation_path
    end
  end

  # GET /resource/confirmation/new
  def new
    self.resource = resource_class.new
  end

  # POST /resource/confirmation
  def create
    self.resource = resource_class.send_confirmation_instructions(params[resource_name])

    if resource.errors.empty?
      set_flash_message :notice, :send_instructions
      redirect_to new_session_path(resource_name)
    else
      render 'devise/confirmations/new'
    end
  end

end
