class TeamsController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:switch]
  skip_after_filter :verify_authorized, only: [:switch]
  skip_after_filter :verify_policy_scoped, only: [:switch]

  def switch
    if current_user
      team = current_user.teams.friendly.find(params[:id])
      session[:current_team_slug] = team.slug
    else
      team = Team.friendly.find(params[:id])
      session[:team_slug] = team.slug
    end
    redirect_to root_path
  end
end
