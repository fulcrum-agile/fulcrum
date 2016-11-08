require 'rails_helper'

describe IntegrationsController do
  let(:user)        { create(:user, :with_team_and_is_admin) }
  let(:project)     { create(:project, users: [user], teams: [user.teams.first]) }

  let(:integration) { build(:integration, project: project) }

  context "when logged out" do
    %w[index create].each do |action|
      specify do
        get action, project_id: project.id
        expect(response).to redirect_to(new_user_session_url)
      end
    end
    %w[destroy].each do |action|
      specify do
        get action, id: 42, project_id: project.id
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  context "when logged in" do

    before do
      sign_in user
      allow(subject).to receive_messages(current_user: user, current_team: user.teams.first)
    end

    describe "collection actions" do

      describe "#index" do
        before { integration.save }

        context "as html" do
          specify do
            get :index, project_id: project.id
            expect(response).to be_success
            expect(assigns[:project]).to eq(project)
          end
        end

        context "as json" do
          specify do
            xhr :get, :index, project_id: project.id, format: :json
            expect(response).to be_success
            expect(JSON.parse(response.body).first["integration"]["data"]).to eql(integration.data)
          end

        end

      end

      describe "#create" do

        let(:integration_params) {{
          "kind" => integration.kind,
          "data" => integration.data.to_json
        }}

        specify do
          expect {
            post :create, project_id: project.id, integration: integration_params
          }.to change { Integration.count }.by(1)
          expect(assigns[:project]).to eq(project)
          expect(assigns[:integration].kind).to eq(integration_params["kind"])
          expect(assigns[:integration].data).to eq(JSON.parse integration_params["data"])
          expect(response).to redirect_to(edit_project_url(project))
        end

        context "when integration does not exist" do

          context "when save fails" do
            before {
              integration_params[:kind] = nil
            }

            specify do
              expect {
                post :create, project_id: project.id, integration: integration_params
              }.to change { Integration.count }.by(0)
              expect(response).to render_template('index')
            end
          end

          context "when a invalid json is inserted" do
            before { integration_params[:data] = nil }

            specify do
              expect {
                post :create, project_id: project.id, integration: integration_params
              }.to change { Integration.count }.by(0)
              expect(response).to render_template('index')
            end
          end

          context "when save succeeds" do

            specify do
              post :create, project_id: project.id, integration: integration_params
              expect(flash[:notice]).to eq("#{integration.kind} was added to this project")
            end

          end
        end

        context "when integration exists" do
          before { integration.save }

          specify do
            expect {
              post :create, project_id: project.id, integration: integration_params
            }.to change { Integration.count }.by(0)
            expect(flash[:alert]).to eq("#{integration.kind} is already configured for this project")
          end
        end
      end
    end

    describe "integration actions" do
      before { integration.save }

      describe "#destroy" do

        specify do
          delete :destroy, project_id: project.id, id: integration.id
          expect(response).to redirect_to(edit_project_url(project))
        end

      end

    end

  end
end

