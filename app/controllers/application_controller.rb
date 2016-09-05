class ApplicationController < ActionController::Base
  protect_from_forgery

  include Pundit

  before_filter :authenticate_user!, :set_locale
  around_filter :user_time_zone, if: :current_user

  after_filter :verify_authorized, except: [:index], unless: :devise_controller?
  after_filter :verify_policy_scoped, only: [:index], unless: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from Pundit::NotAuthorizedError,   with: :user_not_authorized

  protected
  def render_404
    respond_to do |format|
      format.html do
        render file: Rails.root.join('public', '404.html'),
          status: '404'
      end
      format.xml do
        render nothing: true, status: '404'
      end
    end
  end

  private

  def set_locale
    if !current_user.nil? && !current_user.locale.nil? && !current_user.locale.empty?
      I18n.locale = current_user.locale.to_sym
    else
      I18n.locale = :en
    end
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

  def current_team
    # FIXME hardcoding a team until the sign in process adds the Team check
    session[:current_team] || Team.first
  end
  helper_method :current_team
end
