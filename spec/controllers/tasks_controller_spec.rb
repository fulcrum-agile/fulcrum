require 'spec_helper'

describe TasksController do
  
  let(:user)            { FactoryGirl.create :user }
  let(:project)         { mock_model(Project, :id => 42) }
  let(:story)           { mock_model(Story, :id => 99) }
  let(:projects)        { double("projects") }
  let(:stories)         { double("stories") }
  let(:tasks)           { double("tasks", :to_json => '{foo:bar}') }
  let(:task)            { mock_model(Task, :id => 66, :to_json => '{foo:bar}') }
  let(:request_params)  { {:project_id => project.id, :story_id => story.id } }

  context "when not logged in" do

    describe "collection actions" do

      specify "#create" do
        xhr :post, :create, request_params
        response.status.should == 401
      end

    end

    describe "member actions" do

      before do
        request_params[:id] = task.id
      end

      specify "#destroy" do
        xhr :delete, :destroy, request_params
        response.status.should == 401
      end

    end

  end


  context "when logged in" do


    before do
      user.stub(:projects => projects)
      projects.stub(:find).with(project.id.to_s).and_return(project)
      project.stub(:stories => stories)
      stories.stub(:find).with(story.id.to_s).and_return(story)
      story.stub(:tasks => tasks)
      tasks.stub(:find).with(task.id.to_s).and_return(task)
      subject.stub(:current_user => user)

      sign_in user
    end

    describe "collection actions" do

      describe "#create" do

        before do
          request_params[:task] = {'task' => 'foo'}
          tasks.should_receive(:build).with(request_params[:task]).and_return(task)
          task.stub(:save => true)
        end

        specify do
          xhr :post, :create, request_params
          response.should be_success
          assigns[:project].should == project
          assigns[:story].should == story
          assigns[:task].should == task
          response.content_type.should == 'application/json'
          response.body.should == task.to_json
        end

        context "when save fails" do

          before do
            task.stub(:save => false)
          end

          specify do
            xhr :post, :create, request_params
            response.status.should == 422
          end
          
        end

      end

    end

    describe "member actions" do

      let(:request_params) { 
        {:id => task.id, :project_id => project.id, :story_id => story.id}
      }

      describe "#destroy" do

        before do
          task.should_receive(:destroy)
        end

        specify do
          xhr :delete, :destroy, request_params
          response.should be_success
          assigns[:project].should == project
          assigns[:story].should == story
          assigns[:task].should == task
          response.body.should be_blank
        end
      end

    end

  end

end
