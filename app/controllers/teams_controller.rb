class TeamsController < ApplicationController
  skip_before_filter :check_team_presence, only: [:index, :switch, :new, :create]
  skip_after_filter :verify_policy_scoped, only: :index

  def index
    @teams = current_user.teams
    authorize @teams
  end

  def switch
    team = current_user.teams.friendly.find(params[:team_slug])
    authorize team
    session[:current_team_slug] = team.slug
    redirect_to root_path
  end

  # GET /teams/new
  # GET /teams/new.xml
  def new
    @team = Team.new
    authorize @team
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @team }
    end
  end

  # GET /teams/1/edit
  def edit
    @team = current_team
    @user_teams = current_user.teams.order(:name)

    authorize @team
  end

  # POST /teams
  # POST /teams.xml
  def create
    @team = Team.new(allowed_params)
    authorize @team
    respond_to do |format|
      if verify_recaptcha && ( @team = TeamOperations::Create.(@team, current_user) )
        format.html do
          session[:current_team_slug] = @team.slug
          flash[:notice] = t('teams.team was successfully created')
          redirect_to(root_path)
        end
        format.xml  { render xml: @team, status: :created, location: @team }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /teams/1
  # PUT /teams/1.xml
  def update
    @team = current_team
    authorize @team

    respond_to do |format|
      if TeamOperations::Update.(@team, allowed_params, current_user)
        @team.reload

        format.html do
          flash[:notice] = t('teams.team was successfully updated')
          render action: "edit"
        end
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.xml
  def destroy
    @team = current_team
    authorize @team

    TeamOperations::Destroy.(@team, current_user)
    session[:current_team_slug] = nil

    respond_to do |format|
      format.html { redirect_to root_path }
      format.xml  { head :ok }
    end
  end

  protected

  def allowed_params
    params.require(:team).permit(:name, :disable_registration, :registration_domain_whitelist, :registration_domain_blacklist,
                                logo: [ :id, :public_id, :version, :signature, :width, :height, :format, :resource_type, :created_at, :tags, :bytes, :type, :etag, :url, :secure_url, :original_filename ])
  end

end
