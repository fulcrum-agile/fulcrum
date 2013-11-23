require 'spec_helper'

describe ProjectsController do

  context "when logged out" do
    %W[index new create].each do |action|
      specify do
        get action
        response.should redirect_to(new_user_session_url)
      end
    end
    %W[show edit update destroy].each do |action|
      specify do
        get action, :id => 42
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  context "when logged in" do

    let(:user)      { FactoryGirl.create :user }
    let(:projects)  { double("projects") }

    before do
      sign_in user
      subject.stub(:current_user => user)
      user.stub(:projects => projects)
    end

    describe "collection actions" do

      describe "#index" do

        specify do
          get :index
          response.should be_success
          assigns[:projects].should == projects
        end

      end

      describe "#new" do

        specify do
          get :new
          response.should be_success
          assigns[:project].should be_new_record
        end

      end

      describe "#create" do

        let(:project) { mock_model(Project) }
        let(:users)   { double("users") }

        before do
          projects.stub(:build).with({}) { project }
          project.stub(:users => users)
          users.should_receive(:<<).with(user)
          project.stub(:save => true)
        end

        specify do
          post :create, :project => {}
          assigns[:project].should == project
        end

        context "when save succeeds" do

          specify do
            post :create, :project => {}
            response.should redirect_to(project_url(project))
            flash[:notice].should == 'Project was successfully created.'
          end

        end

        context "when save fails" do

          before do
            project.stub(:save => false)
          end

          specify do
            post :create, :project => {}
            response.should be_success
            response.should render_template('new')
          end

        end

      end

    end

    describe "member actions" do

      let(:project) { mock_model(Project, :id => 42, :to_json => '{foo:bar}') }
      let(:story)   { mock_model(Story) }

      before do
        projects.stub(:find).with(project.id.to_s) { project }
        project.stub_chain(:stories, :build) { story }
      end

      describe "#show" do

        context "as html" do

          specify do
            get :show, :id => project.id
            response.should be_success
            assigns[:project].should == project
            assigns[:story].should == story
          end

        end

        context "as json" do

          specify do
            xhr :get, :show, :id => project.id
            response.should be_success
            assigns[:project].should == project
            assigns[:story].should == story
          end

        end

      end

      describe "#edit" do

        let(:users) { double("users") }

        before do
          project.stub(:users => users)
          users.should_receive(:build)
        end

        specify do
          get :edit, :id => project.id
          response.should be_success
          assigns[:project].should == project
        end

      end

      describe "#update" do

        before do
          project.stub(:update_attributes).with({}) { true }
        end

        specify do
          put :update, :id => project.id, :project => {}
          assigns[:project].should == project
        end

        context "when update succeeds" do

          specify do
            put :update, :id => project.id, :project => {}
            response.should redirect_to(project_url(project))
          end

        end

        context "when update fails" do

          before do
            project.stub(:update_attributes).with({}) { false }
          end

          specify do
            put :update, :id => project.id, :project => {}
            response.should be_success
            response.should render_template('edit')
          end

        end

      end

      describe "#destroy" do

        before do
          project.should_receive(:destroy)
        end

        specify do
          delete :destroy, :id => project.id
          response.should redirect_to(projects_url)
        end

      end

    end

  end

end
