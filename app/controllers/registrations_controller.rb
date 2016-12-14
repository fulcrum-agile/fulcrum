class RegistrationsController < Devise::RegistrationsController
  prepend_before_action :check_captcha, only: :create
  before_filter :set_locale, only: :create
  before_filter :check_registration_enabled, only: [:new, :create]
  before_filter :devise_params
  after_filter :reset_locale, only: :update

  def disable_two_factor
    verify_token = Authy::API.verify(id: current_user.authy_id, token: params[:token], force: true)

    if verify_token.ok?
      disable_authy = Authy::API.delete_user(id: current_user.authy_id)

      if disable_authy.ok?
        current_user.update(authy_id: nil, authy_enabled: false)

        set_flash_message :notice, :disabled, scope: 'devise.devise_authy'
        redirect_to edit_user_registration_path
      else
        set_flash_message :error, :not_disabled, now: true, scope: 'devise.devise_authy'
        render :verify_two_factor
      end
    else
      set_flash_message :error, :invalid_token, now: true, scope: 'devise.devise_authy'
      render :verify_two_factor
    end
  end

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

    def set_locale
      return unless resource
      if session[:locale]
        resource.locale = session[:locale]
      else
        resource.locale = I18n.locale
      end
    end

    def reset_locale
      session[:locale] = nil
    end
end
