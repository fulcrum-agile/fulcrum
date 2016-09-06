class StoriesController < ApplicationController

  include ActionView::Helpers::TextHelper

  before_action :set_project
  before_action :filter_documents

  def index
    @stories = if params[:q]
                 StorySearch.query(policy_scope(Story), params[:q])
               elsif params[:label]
                 StorySearch.labels(policy_scope(Story), params[:label])
               else
                 policy_scope(Story).with_dependencies.order('updated_at DESC').tap do |relation|
                   relation = relation.limit(ENV['STORIES_CEILING']) if ENV['STORIES_CEILING']
                 end
               end

    respond_to do |format|
      format.json { render json: @stories }
      format.csv do
        render csv: @stories.order(:position), filename: @project.csv_filename
      end
    end
  end

  def show
    @story = policy_scope(Story)&.with_dependencies&.find(params[:id])
    authorize @story
    render json: @story
  end

  def update
    @story = policy_scope(Story).find(params[:id])
    authorize @story
    @story.acting_user = current_user
    @story.base_uri = project_url(@story.project)
    respond_to do |format|
      if @story = StoryOperations::Update.(@story, allowed_params, current_user)
        format.html { redirect_to project_url(@project) }
        format.js   { render json: @story }
      else
        format.html { render action: 'edit' }
        format.js   { render json: @story, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @story = policy_scope(Story).find(params[:id])
    authorize @story
    StoryOperations::Destroy.(@story, current_user)
    head :ok
  end

  def done
    @stories = policy_scope(Story).done
    authorize Story, :done?
    render json: @stories
  end

  def backlog
    @stories = policy_scope(Story).backlog
    authorize Story, :backlog?
    render json: @stories
  end

  def in_progress
    @stories = policy_scope(Story).in_progress
    authorize Story, :in_progress?
    render json: @stories
  end

  def create
    @story = policy_scope(Story).build(allowed_params)
    authorize @story
    @story.requested_by_id = current_user.id unless @story.requested_by_id
    respond_to do |format|
      if @story = StoryOperations::Create.(@story, current_user)
        format.html { redirect_to project_url(@project) }
        format.js   { render json: @story }
      else
        format.html { render action: 'new' }
        format.js   { render json: @story, status: :unprocessable_entity }
      end
    end
  end

  private

  def allowed_params
    params.require(:story).permit(:title, :description, :estimate, :story_type, :state, :requested_by_id, :owned_by_id, :position, :labels,
                                  documents: [ :id, :public_id, :version, :signature, :width, :height, :format, :resource_type, :created_at, :tags, :bytes, :type, :etag, :url, :secure_url, :original_filename ])
  end

  def filter_documents
    # for some reason, on drag/drop update the hash is coming as:
    #   { documents: [ { file: {id: 1 ...} }, { file: {id: 2 ...} } ]
    # instead of
    #   { documents: [ {id: 1 ...}, {id: 2 ...} ]
    # so this fixes it (avoid story to lose the attachment association
    if params.dig(:story, :documents) && params[:story][:documents].first.has_key?(:file)
      params[:story][:documents] = params[:story][:documents].map{ |hash| hash.values.first }
    end
  end

  def set_project
    @project = policy_scope(Project).friendly.find(params[:project_id])
  end

end
