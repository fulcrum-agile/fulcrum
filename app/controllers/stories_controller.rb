class StoriesController < ApplicationController
  authorize_resource

  include ActionView::Helpers::TextHelper

  before_action :filter_documents

  def index
    @project = current_user.projects.with_stories_notes.friendly.find(params[:project_id])

    @stories = if params[:q]
                 StorySearch.new(@project, params[:q]).search
               elsif params[:label]
                 Story.by_label(params[:label])
               elsif ENV['STORIES_CEILING']
                 @project.stories.order('updated_at DESC').limit(ENV['STORIES_CEILING'])
               else
                 @project.stories
               end

    respond_to do |format|
      format.json { render :json => @stories }
      format.csv do
        render :csv => @stories.order(:position), :filename => @project.csv_filename
      end
    end
  end

  def show
    @project = current_user.projects.find(params[:project_id])
    @story = @project.stories.find(params[:id])
    render :json => @story
  end

  def update
    @project = current_user.projects.find(params[:project_id])
    @story = @project.stories.find(params[:id])
    @story.acting_user = current_user
    @story.base_uri = project_url(@story.project)
    respond_to do |format|
      if @story = StoryOperations::Update.(@story, allowed_params, current_user)
        format.html { redirect_to project_url(@project) }
        format.js   { render :json => @story }
      else
        format.html { render :action => 'edit' }
        format.js   { render :json => @story, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @project = current_user.projects.find(params[:project_id])
    @story = @project.stories.find(params[:id])
    StoryOperations::Destroy.(@story, current_user)
    head :ok
  end

  def done
    @project = current_user.projects.find(params[:project_id])
    @stories = @project.stories.done
    render :json => @stories
  end

  def backlog
    @project = current_user.projects.find(params[:project_id])
    @stories = @project.stories.backlog
    render :json => @stories
  end

  def in_progress
    @project = current_user.projects.find(params[:project_id])
    @stories = @project.stories.in_progress
    render :json => @stories
  end

  def create
    @project = current_user.projects.find(params[:project_id])
    @story = @project.stories.build(allowed_params)
    @story.requested_by_id = current_user.id unless @story.requested_by_id
    respond_to do |format|
      if @story = StoryOperations::Create.(@story, current_user)
        format.html { redirect_to project_url(@project) }
        format.js   { render :json => @story }
      else
        format.html { render :action => 'new' }
        format.js   { render :json => @story, :status => :unprocessable_entity }
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
end
