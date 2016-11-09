class LocalesController < ApplicationController
  LOCALES = {
    'English'    => 'en',
    'Español'    => 'es',
    'Português'  => 'pt-BR'
  }

  skip_before_filter :authenticate_user!, only: [:update]
  skip_after_filter :verify_authorized, only: [:update]
  skip_after_filter :verify_policy_scoped, only: [:update]

  def update
    if LOCALES.values.include?(params[:locale])
      session[:locale] = params[:locale]
    end
    redirect_to request.referer || root_path
  end
end
