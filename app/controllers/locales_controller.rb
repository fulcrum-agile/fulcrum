class LocalesController < ApplicationController
  skip_before_filter :check_team_presence

  options = { :class => 'locale-change-option' }
  LOCALES = [
    [ 'English', 'en', options ],
    [ 'Español', 'es', options ],
    [ 'Português', 'pt-BR', options ]
  ]

  skip_before_filter :authenticate_user!, only: [:update]
  skip_after_filter :verify_authorized, only: [:update]
  skip_after_filter :verify_policy_scoped, only: [:update]

  def update
    if LOCALES.any? { |locale| locale.include?(params[:locale]) }
      session[:locale] = params[:locale]
    end
    redirect_to request.referer || root_path
  end
end
