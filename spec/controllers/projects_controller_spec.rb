require 'rails_helper'

describe ProjectsController do

  context "when logged out" do
    %W[index new create].each do |action|
      specify do
        get action
        expect(response).to redirect_to(new_user_session_url)
      end
    end
    %W[show edit update destroy].each do |action|
      specify do
        get action, id: 42
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  context "when logged in" do

    let(:user)      { FactoryGirl.create :user }
    let(:projects)  { double("projects") }
    let(:project)   { mock_model(Project, id: 99, stories: stories) }
    let(:stories)   { double("stories", to_json: '{foo:bar}') }

    before do
      sign_in user
      allow(subject).to receive_messages(current_user: user)
      allow(user).to receive_messages(projects: projects)
      allow(user).to receive_message_chain(:projects, :not_archived) { projects }
    end

    describe "collection actions" do

      describe "#index" do

        specify do
          get :index
          expect(response).to be_success
          expect(assigns[:projects]).to eq(projects)
        end

      end

      describe "#new" do

        specify do
          get :new
          expect(response).to be_success
          expect(assigns[:project]).to be_new_record
        end

      end

      describe "#create" do

        let(:project) { mock_model(Project) }
        let(:users)   { double("users") }

        before do
          allow(projects).to receive(:build).with({}) { project }
          allow(project).to receive_messages(users: users)
          expect(users).to receive(:<<).with(user)
          allow(ProjectOperations::Create).to receive(:call).with(project, user).and_return(project)
        end

        specify do
          post :create, project: {}
          expect(assigns[:project]).to eq(project)
        end

        context "when save succeeds" do

          specify do
            post :create, project: {}
            expect(response).to redirect_to(project_url(project))
            expect(flash[:notice]).to eq('Project was successfully created.')
          end

        end

        context "when save fails" do

          before do
            allow(ProjectOperations::Create).to receive(:call).with(project, user).and_return(false)
          end

          specify do
            post :create, project: {}
            expect(response).to be_success
            expect(response).to render_template('new')
          end

        end

      end

      describe "#archived" do
        let(:archived_project) { FactoryGirl.create :project,
          archived_at: Time.current }

        before do
          get :archived
        end

        it "returns success" do
          expect(response).to be_success
        end

        it "assigns projects" do
          expect(assigns[:projects]).to include archived_project
        end
      end

    end

    describe "member actions" do

      let(:project) { mock_model(Project, id: 42, to_json: '{foo:bar}') }
      let(:story)   { mock_model(Story) }

      before do
        allow(projects).to receive_message_chain(:friendly, :find).with(project.id.to_s) { project }
        allow(project).to receive_message_chain(:stories, :build) { story }
        allow(project).to receive(:"import=").and_return(nil)
      end

      describe "#show" do

        context "as html" do

          specify do
            get :show, id: project.id
            expect(response).to be_success
            expect(assigns[:project]).to eq(project)
            expect(assigns[:story]).to eq(story)
          end

        end

        context "as json" do

          specify do
            xhr :get, :show, id: project.id
            expect(response).to be_success
            expect(assigns[:project]).to eq(project)
            expect(assigns[:story]).to eq(story)
          end

        end

      end

      describe "#edit" do

        let(:users) { double("users") }

        before do
          allow(project).to receive_messages(users: users)
          expect(users).to receive(:build)
        end

        specify do
          get :edit, id: project.id
          expect(response).to be_success
          expect(assigns[:project]).to eq(project)
        end

      end

      describe "#update" do

        before do
          allow(ProjectOperations::Update).to receive(:call).with(project, {}, user).and_return(project)
        end

        specify do
          put :update, id: project.id, project: {}
          expect(assigns[:project]).to eq(project)
        end

        context "when update succeeds" do

          specify do
            put :update, id: project.id, project: {}
            expect(response).to redirect_to(project_url(project))
          end

        end

        context "when update fails" do

          before do
            allow(ProjectOperations::Update).to receive(:call).with(project, {}, user).and_return(false)
          end

          specify do
            put :update, id: project.id, project: {}
            expect(response).to be_success
            expect(response).to render_template('edit')
          end

        end

      end

      describe "#destroy" do

        before do
          allow(ProjectOperations::Destroy).to receive(:call).with(project, user).and_return(project)
        end

        specify do
          delete :destroy, id: project.id
          expect(response).to redirect_to(projects_url)
        end

      end

      describe "#import" do
        context "when no job is running" do
          specify do
            get :import, id: project.id
            expect(response).to be_success
            expect(assigns[:project]).to eq(project)
            expect(response).to render_template('import')
          end
        end

        context "when there is a job registered" do

          context "still unprocessed" do
            before do
              session[:import_job] = { id: 'foo', created_at: 10.minutes.ago }
            end

            specify do
              get :import, id: project.id
              expect(assigns[:valid_stories]).to be_nil
              expect(session[:import_job]).not_to be_nil
              expect(response).to render_template('import')
            end
          end

          context "unprocessed for more than 60 minutes" do
            before do
              session[:import_job] = { id: 'foo', created_at: 2.hours.ago }
            end

            specify do
              get :import, id: project.id
              expect(assigns[:valid_stories]).to be_nil
              expect(session[:import_job]).to be_nil
              expect(response).to render_template('import')
            end
          end

          context "finished with errors" do
            let(:error) { "Bad CSV!" }
            before do
              session[:import_job] = { id: 'foo', created_at: 5.minutes.ago }
              expect(Rails.cache).to receive(:read).with('foo').and_return({ invalid_stories: [], errors: error })
            end
            specify do
              get :import, id: project.id
              expect(assigns[:valid_stories]).to be_nil
              expect(flash[:alert]).to eq("Unable to import CSV: Bad CSV!")
              expect(session[:import_job]).to be_nil
              expect(response).to render_template('import')
            end
          end

          context "finished with success" do
            let(:valid_story) { mock_model(Story, valid?: true) }
            let(:invalid_story) { { title: 'hello', errors: 'bad cookie'} }
            before do
              expect(project).to receive(:stories).and_return([valid_story])
              session[:import_job] = { id: 'foo', created_at: 5.minutes.ago }
              expect(Rails.cache).to receive(:read).with('foo').and_return({ invalid_stories: [invalid_story], errors: nil })
            end

            specify do
              get :import, id: project.id
              expect(assigns[:valid_stories]).to eq([valid_story])
              expect(assigns[:invalid_stories]).to eq([invalid_story])
              expect(flash[:notice]).to eq("Imported 1 story")
              expect(session[:import_job]).to be_nil
              expect(response).to render_template('import')
            end
          end
        end
      end

      describe "#import_upload" do
        context "when csv file is missing" do
          specify do
            put :import_upload, id: project.id, project: { import: "" }
            expect(response).to redirect_to(import_project_path(project.id))
            expect(flash[:alert]).to eq("You must select a file for import")
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
            expect(ImportWorker).to receive(:perform_async)
            put :import_upload, id: project.id, project: { import: csv }
            expect(flash[:notice]).to eq("Your upload is being processed. You can come back here later.")
            expect(response).to redirect_to(import_project_path(project.id))
          end

        end

      end

    end

  end

end
