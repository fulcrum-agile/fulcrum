class TeamsController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:switch, :new, :create]
  skip_after_filter :verify_authorized, only: [:switch, :new, :create]
  skip_after_filter :verify_policy_scoped, only: [:switch, :new]

  def switch
    if current_user
      team = current_user.teams.friendly.find(params[:id])
      session[:current_team_slug] = team.slug
    else
      team = Team.not_archived.friendly.find(params[:id])
      session[:team_slug] = team.slug
    end
    redirect_to root_path
  end

  # GET /teams/new
  # GET /teams/new.xml
  def new
    @team = Team.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @team }
    end
  end

  def show
    redirect_to edit_team_path(current_team)
  end

  # GET /teams/1/edit
  def edit
    @team = current_team
    authorize @team
  end

  # POST /teams
  # POST /teams.xml
  def create
    @team = Team.new(allowed_params)

    respond_to do |format|
      if verify_recaptcha && ( @team = TeamOperations::Create.(@team, current_user) )
        format.html do
          session[:team_slug] = @team.slug
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
