require 'open-uri'
class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy import import_upload reports]

  # GET /projects
  # GET /projects.xml
  def index
    @projects = policy_scope(Project).not_archived

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @story = @project.stories.build

    respond_to do |format|
      format.html # show.html.erb
      format.js   { render json: @project }
      format.xml  { render xml: @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = policy_scope(Project).new
    authorize @project

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project.users.build
    authorize @project
    @integration = Integration.new
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = policy_scope(Project).new(allowed_params)
    authorize @project
    @project.users << current_user

    respond_to do |format|
      if ProjectOperations::Create.(@project, current_user)
        format.html { redirect_to(@project, notice: t('projects.project was successfully created')) }
        format.xml  { render xml: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @integration = Integration.new

    respond_to do |format|
      if ProjectOperations::Update.(@project, allowed_params, current_user)
        format.html { redirect_to(@project, notice: t('projects.project was successfully updated')) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    ProjectOperations::Destroy.(@project, current_user)

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end

  # CSV import form
  def import
    if session[:import_job]
      if job_result = Rails.cache.read(session[:import_job][:id])
        session[:import_job] = nil
        if job_result[:errors]
          flash[:alert] = "Unable to import CSV: #{job_result[:errors]}"
        else
          @valid_stories    = @project.stories
          @invalid_stories  = job_result[:invalid_stories]

          flash[:notice] = I18n.t(
            'imported n stories', count: @valid_stories.count
          )

          unless @invalid_stories.empty?
            flash[:alert] = I18n.t(
              'n stories failed to import', count: @invalid_stories.count
            )
          end
        end
      else
        minutes_ago = (Time.current - session[:import_job][:created_at]) / 1.minute
        if minutes_ago > 60
          session[:import_job] = nil
        end
      end
    end
  end

  # CSV import
  def import_upload
    if params[:project][:import].blank?
      flash[:alert] = I18n.t('projects.uploads.select_file')
    else
      session[:import_job] = { id: ImportWorker.new_job_id, created_at: Time.current }

      @project.update_attributes(allowed_params)
      ImportWorker.perform_async(session[:import_job][:id], params[:id])

      flash[:notice] = I18n.t('projects.uploads.being_processed')
    end

    redirect_to [:import, @project]
  end

  def archived
    @projects = policy_scope(Project).archived
    authorize @projects
  end

  def reports
    since = params[:since].nil? ? nil : params[:since].to_i.months.ago
    @service = IterationService.new(@project, since)
  end

  protected

  def allowed_params
    params.fetch(:project,{}).permit(:name, :point_scale, :default_velocity, :start_date, :iteration_start_day, :iteration_length, :import, :archived)
  end

  def set_project
    @project = policy_scope(Project).friendly.find(params[:id])
    authorize @project
  end

end
