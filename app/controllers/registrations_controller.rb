class RegistrationsController < Devise::RegistrationsController
  protected
    def after_inactive_sign_up_path_for(resource)
      new_session_path(resource)
    end
end

