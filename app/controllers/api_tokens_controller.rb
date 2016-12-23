class ApiTokensController < ApplicationController
  before_action :set_team

  def create
    @api_token = @team.api_tokens.create
    redirect_to edit_team_path(@team)
  end

  def destroy
    @api_token = @team.api_tokens.find(params[:id])

    @api_token.destroy
    redirect_to edit_team_path(@team)
  end

  private

  def set_team
    @team ||= current_user.teams.friendly.find(params[:team_id])
    authorize @team
  end
end
