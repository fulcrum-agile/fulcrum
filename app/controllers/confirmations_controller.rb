class ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    
    if resource.errors.empty?
      set_flash_message :notice, :confirmed
      redirect_to edit_user_password_path(:reset_password_token => resource.reset_password_token)
    else
      render_with_scope :new
    end
  end

end