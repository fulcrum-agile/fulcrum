class RegistrationsController < Devise::RegistrationsController
  before_filter :check_registration_enabled, :only => [:new, :create]
  protected
    def after_inactive_sign_up_path_for(resource)
      new_session_path(resource)
    end


    def check_registration_enabled
      if Fulcrum::Application.config.fulcrum.disable_registration
        render_404 and return
      end
    end
end

