class ApplicationController < ActionController::Base
  protect_from_forgery

  include Pundit

  before_filter :authenticate_user!, unless: :devise_controller?
  before_filter :set_locale
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
    options = [session[:locale], current_user.try(:locale).try(:to_sym), :en]
    I18n.locale = (options & I18n.available_locales).first
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
    session[:current_team_slug] = current_user.teams&.not_archived&.first&.slug if current_user && session[:current_team_slug].nil?
    raise ActiveRecord::RecordNotFound, 'Team not set' unless session[:current_team_slug]
    @current_team ||= Team.not_archived.find_by_slug(session[:current_team_slug])
  end
  helper_method :current_team

  def after_sign_in_path_for(resource)
    if params.dig(:user, :reset_password_token)
      session[:current_team_slug] = current_user.try(:teams).try(:first).try(:slug)
    elsif params.dig(:user, :team_slug)
      session[:current_team_slug] = params[:user][:team_slug]
    end
    super
  end

  def must_pundit?
    !devise_controller? && !(self.class.parent == Manage)
  end
end
