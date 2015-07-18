require 'rails_helper'

describe StoriesController do

  describe "when logged out" do
    %w[index done backlog in_progress create].each do |action|
      specify do
        get action, :project_id => 99
        response.should redirect_to(new_user_session_url)
      end
    end

    %w[show update destroy start finish deliver accept reject].each do |action|
      specify do
        get action, :project_id => 99, :id => 42
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  context "when logged in" do

    let(:user)      { FactoryGirl.create(:user) }
    let(:project)   { mock_model(Project, :id => 99, :stories => stories) }
    let(:story)     { mock_model(Story, :id => 42) }
    let(:projects)  { double("projects") }
    let(:stories)   { double("stories", :to_json => '{foo:bar}') }

    before do
      subject.stub(:current_user) { user }
      user.stub(:projects) { projects }
      projects.stub(:find).with(project.id.to_s) { project }
      sign_in user
    end

    describe "#index" do

      before do
        projects.unstub(:find)
        projects.stub(:stories_notes)
        projects.stub_chain(:with_stories_notes, :friendly, :find).with(
          project.id.to_s
        ) { project }
      end

      specify do
        xhr :get, :index, :project_id => project.id, :id => story.id
        response.should be_success
        response.body.should == stories.to_json
      end
    end

    context "member actions" do

      let(:story) { mock_model(Story, :to_json => '{foo:bar}') }
      # The "foo" key should be stripped from this hash by the controller
      let(:story_params)  { {'title' => 'New Title', 'foo' => 'Bar'} }


      before do
        stories.stub(:find).with(story.id.to_s) { story }
        projects.stub(:find).with(project.id.to_s) { project }
      end

      describe "#show" do
        specify do
          xhr :get, :show, :project_id => project.id, :id => story.id
          response.should be_success
          response.body.should == story.to_json
        end
      end

      describe "#update" do

        before do
          story.should_receive(:acting_user=).with(user)
        end

        context "when update succeeds" do

          before do
            story.should_receive(:update_attributes).with(
              {'title' => 'New Title'}
            ) { true }
          end

          specify do
            xhr :get, :update, :project_id => project.id, :id => story.id,
              :story => story_params
            response.should be_success
            response.body.should == story.to_json
          end

        end

        context "when update fails" do

          before do
            story.should_receive(:update_attributes).with(
              {'title' => 'New Title'}
            ) { false }
          end

          specify do
            xhr :get, :update, :project_id => project.id, :id => story.id,
              :story => story_params
            response.status.should == 422
            response.body.should == story.to_json
          end
        end
      end

      describe "#destroy" do

        before { story.should_receive(:destroy) }

        specify do
          xhr :delete, :destroy, :project_id => project.id, :id => story.id
          response.should be_success
        end
      end

      %w[done backlog in_progress].each do |action|

        let(:scoped_stories)  { double("scoped_stories", :to_json => '{scoped:y}') }

        describe action do

          before do
            stories.should_receive(action) { scoped_stories }
          end

          specify do
            xhr :get, action, :project_id => project.id, :id => story.id
            response.should be_success
            response.body.should == scoped_stories.to_json
          end
        end
      end

      describe "#create" do

        before do
          stories.should_receive(:build).with(
            {'title' => 'New Title'}
          ) { story }
          story.should_receive(:requested_by_id=).with(user.id)
        end

        context "when save succeeds" do

          before do
            story.should_receive(:save) { true }
          end

          specify do
            xhr :post, :create, :project_id => project.id, :id => story.id,
              :story => story_params
            response.should be_success
            response.body.should == story.to_json
          end
        end

        context "when save fails" do

          before do
            story.should_receive(:save) { false }
          end

          specify do
            xhr :post, :create, :project_id => project.id, :id => story.id,
              :story => story_params
            response.status.should == 422
            response.body.should == story.to_json
          end
        end

      end

      %w[start finish deliver accept reject].each do |action|

        describe action do
          before do
            story.should_receive("#{action}!")
          end
          specify do
            xhr :put, action, :project_id => project.id, :id => story.id
            response.should redirect_to(project_url(project))
          end
        end

      end

    end
  end
end
