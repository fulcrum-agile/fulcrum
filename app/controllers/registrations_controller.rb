class RegistrationsController < Devise::RegistrationsController
  before_filter :check_registration_enabled, :only => [:new, :create]
  before_filter :devise_params

  protected
    def after_inactive_sign_up_path_for(resource)
      new_session_path(resource)
    end

    def check_registration_enabled
      if Fulcrum::Application.config.fulcrum.disable_registration
        render_404 and return
      end
    end

    def devise_params
      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit( :email, :name, :initials )
      end
      devise_parameter_sanitizer.for(:account_update) do |u|
        u.permit( :email, :password, :password_confirmation, :remember_me,
                  :name, :initials, :email_delivery, :email_acceptance,
                  :email_rejection, :locale, :current_password )
      end
    end
end
