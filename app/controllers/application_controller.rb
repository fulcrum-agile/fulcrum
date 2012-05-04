class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!, :set_locale

  # Handle unauthorized access with a good old fashioned 'forbidden'
  rescue_from CanCan::AccessDenied do |exception|
    render :file => "#{Rails.root}/public/403.html", :status => :forbidden
  end

  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  protected
  def render_404
    respond_to do |format|
      format.html do
        render :file => Rails.root.join('public', '404.html'),
          :status => '404'
      end
      format.xml do
        render :nothing => true, :status => '404'
      end
    end
  end

  private 

  def set_locale
    if !current_user.nil? && !current_user.locale.nil?
      I18n.locale = current_user.locale.to_sym 
    end
  end
end
