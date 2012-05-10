class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!, :set_locale

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
    if !current_user.nil? && !current_user.locale.nil? && !current_user.locale.empty?
      I18n.locale = current_user.locale.to_sym 
    else
      I18n.locale = :en
    end
  end
end
