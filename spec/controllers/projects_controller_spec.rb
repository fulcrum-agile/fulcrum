require 'rails_helper'

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
    let(:project)   { mock_model(Project, :id => 99, :stories => stories) }
    let(:stories)   { double("stories", :to_json => '{foo:bar}') }

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
        projects.stub_chain(:friendly, :find).with(project.id.to_s) { project }
        project.stub_chain(:stories, :build) { story }
        project.stub(:"import=").and_return(nil)
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

      describe "#import" do
        context "when no job is running" do
          specify do
            get :import, :id => project.id
            response.should be_success
            assigns[:project].should == project
            response.should render_template('import')
          end
        end

        context "when there is a job registered" do

          context "still unprocessed" do
            before do
              session[:import_job] = { id: 'foo', created_at: 10.minutes.ago }
            end

            specify do
              get :import, :id => project.id
              assigns[:stories].should be_nil
              session[:import_job].should_not be_nil
              response.should render_template('import')
            end
          end

          context "unprocessed for more than 60 minutes" do
            before do
              session[:import_job] = { id: 'foo', created_at: 2.hours.ago }
            end

            specify do
              get :import, :id => project.id
              assigns[:stories].should be_nil
              session[:import_job].should be_nil
              response.should render_template('import')
            end
          end

          context "finished with errors" do
            let(:error) { CSV::MalformedCSVError.new("Bad CSV!") }
            before do
              error.should_receive(:message).and_return("Bad CSV!")
              session[:import_job] = { id: 'foo', created_at: 5.minutes.ago }
              Rails.cache.should_receive(:read).with('foo').and_return({ stories: [], errors: error })
            end
            specify do
              get :import, :id => project.id
              assigns[:stories].should be_nil
              flash[:alert].should == "Unable to import CSV: Bad CSV!"
              session[:import_job].should be_nil
              response.should render_template('import')
            end
          end

          context "finished with success" do
            let(:valid_story) { mock_model(Story, :valid? => true) }
            let(:invalid_story) { mock_model(Story, :valid? => false) }
            let(:stories) { [valid_story, invalid_story] }
            before do
              session[:import_job] = { id: 'foo', created_at: 5.minutes.ago }
              Rails.cache.should_receive(:read).with('foo').and_return({ stories: stories, errors: nil })
            end

            specify do
              get :import, :id => project.id
              assigns[:stories].should == stories
              assigns[:valid_stories].should == [valid_story]
              assigns[:invalid_stories].should == [invalid_story]
              flash[:notice].should == "Imported 1 story"
              session[:import_job].should be_nil
              response.should render_template('import')
            end
          end
        end
      end

      describe "#import_upload" do
        context "when csv file is missing" do
          specify do
            put :import_upload, :id => project.id, :project => { :import => "" }
            response.should redirect_to(import_project_path(project.id))
            flash[:alert].should == "You must select a file for import"
          end
        end

        context "when csv file is present" do

          let(:csv)             { fixture_file_upload('csv/stories.csv') }
          let(:import)          { mock_model(Attachinary::File, fullpath: csv )}

          before do
            allow(project).to receive(:update_attributes).and_return(true)
            allow(project).to receive(:import) { import }
          end

          specify do
            ImportWorker.should_receive(:perform_async)
            put :import_upload, :id => project.id, :project => { :import => csv }
            flash[:notice].should == "Your upload is being processed."
            response.should redirect_to(import_project_path(project.id))
          end

        end

      end

    end

  end

end
