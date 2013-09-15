class API::V1::ProjectsController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  respond_to :json
  def update
    @project = Project.where({:id => params[:id], :api_token => params[:token]}).first
    unless @project.nil?
      params["commits"].each do |commit|
        fixed_stories_in_commit = commit["message"].scan(/fixes fulcrum #\d+/)
    #    #delivered = commit["message"].scan(/delivers fulcrum #\d+/)
        fixed_stories_in_commit.each do |fixed_story|
          story = @project.stories.find(fixed_story.sub!("fixes fulcrum #", ""))
          if story.state.eql?"started"
             note_string = "Commit ##{commit["node"]} By #{commit["author"]} \n#{commit["message"]}"
             note = story.notes.new(:note => note_string)
             note.user = story.owned_by
             note.save!
             story.send(:finish!)
             respond_to do |format|
               format.json {render :json => {:status => "OK"}}
             end
          else no_update_response
          end

        end
      end
    else
      no_update_response
    end
  end
end

def no_update_response
  respond_to do |format|
    format.json {render :json => {:status => "No Update made"}}
  end
end