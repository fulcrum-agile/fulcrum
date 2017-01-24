class ApplicationController < ActionController::Base
  protect_from_forgery

  include Pundit

  before_filter :authenticate_user!, unless: :devise_controller?
  before_filter :check_team_presence, unless: :devise_controller?
  before_filter :set_locale
  before_filter :set_layout_settings
  around_filter :user_time_zone, if: :current_user

  after_filter :verify_authorized, except: [:index], if: :must_pundit?
  after_filter :verify_policy_scoped, only: [:index], if: :must_pundit?

  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from Pundit::NotAuthorizedError,   with: :user_not_authorized

  protected

  def render_404
    respond_to do |format|
      format.html do
        if current_user
          redirect_to( request.referer || root_path, alert: I18n.t('not_found') )
        else
          render file: Rails.root.join('public', '404.html'), status: '404'
        end
      end
      format.xml { render nothing: true, status: '404' }
    end
  end

  def set_locale
    options = [session[:locale], current_user&.locale, 'en']
    I18n.locale = (options & I18n.available_locales.map(&:to_s)).first
  end

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  def user_not_authorized
    flash[:error] = t('users.You are not authorized to perform this action')
    redirect_to request.headers["Referer"] || root_path
  end

  def pundit_user
    PunditContext.new(current_team, current_user, { current_project: @project, current_story: @story })
  end
  helper_method :pundit_user

  def current_team
    @current_team ||= Team.not_archived.find_by_slug(session[:current_team_slug])
  end
  helper_method :current_team

  def after_sign_in_path_for(resource)
    if resource.authy_enabled && resource.authy_id.blank?
      return send("#{resource_name}_enable_authy_path")
    end

    return teams_url if session[:current_team_slug].blank?
    super
  end

  def check_team_presence
    redirect_to teams_url if current_team.blank?
  end

  def must_pundit?
    !devise_controller? && !(self.class.parent == Manage)
  end

  def set_layout_settings
    @layout_settings_default = { fluid: false }.freeze
    @layout_settings = @layout_settings_default.dup
  end
end
