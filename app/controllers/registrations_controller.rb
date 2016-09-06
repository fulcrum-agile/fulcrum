class RegistrationsController < Devise::RegistrationsController
  prepend_before_action :check_captcha, only: [:create]
  before_filter :check_registration_enabled, only: [:new, :create]
  before_filter :devise_params

  protected
    def after_inactive_sign_up_path_for(resource)
      new_session_path(resource)
    end

    def check_registration_enabled
      team_slug = resource.try(:team_slug) || session[:team_slug]
      if team_slug
        team = Team.not_archived.find_by_slug(team_slug)
        if team.disable_registration
          render_404 and return
        else
          if resource && !team.allowed_domain?(resource.email)
            render_404 and return
          end
        end
      elsif Fulcrum::Application.config.fulcrum.disable_registration
        render_404 and return
      end
    end

    def devise_params
      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit( :email, :name, :initials, :username, :team_slug )
      end
      devise_parameter_sanitizer.for(:account_update) do |u|
        u.permit( :email, :password, :password_confirmation, :remember_me,
                  :name, :initials, :username, :email_delivery, :email_acceptance,
                  :email_rejection, :locale, :time_zone, :current_password )
      end
    end

    def check_captcha
      unless verify_recaptcha
        self.resource = resource_class.new sign_up_params
        respond_with_navigational(resource) { render :new }
      end
    end
end
