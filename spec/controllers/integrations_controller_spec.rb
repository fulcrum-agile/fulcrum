require 'rails_helper'

describe IntegrationsController do

  let(:integration) { FactoryGirl.build(:integration) }
  let(:project) { integration.project }

  context "when logged out" do
    %w[index create].each do |action|
      specify do
        get action, :project_id => project.id
        expect(response).to redirect_to(new_user_session_url)
      end
    end
    %w[destroy].each do |action|
      specify do
        get action, :id => 42, :project_id => project.id
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  context "when logged in" do

    let(:user)  { FactoryGirl.create(:user) }
    let(:projects)  { double("projects") }

    before do
      sign_in user
      allow(subject).to receive_messages(:current_user => user)
      allow(user).to receive_messages(:projects => projects)
      allow(projects).to receive_message_chain(:friendly, :find).with(project.id.to_s) { project }
    end

    describe "collection actions" do

      describe "#index" do
        before { integration.save }

        context "as html" do
          specify do
            get :index, :project_id => project.id
            expect(response).to be_success
            expect(assigns[:project]).to eq(project)
            expect(assigns[:integrations].to_a).to eq([ integration ])
          end
        end

        context "as json" do
          specify do
            xhr :get, :index, :project_id => project.id, :format => :json
            expect(response).to be_success
            expect(response.body).to eq(assigns[:integrations].to_json)
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
            post :create, :project_id => project.id, :integration => integration_params
          }.to change { Integration.count }.by(1)
          expect(assigns[:project]).to eq(project)
          expect(assigns[:integration].kind).to eq(integration_params["kind"])
          expect(assigns[:integration].data).to eq(JSON.parse integration_params["data"])
          expect(response).to redirect_to(project_integrations_url(project))
        end

        context "when integration does not exist" do

          context "when save fails" do
            before {
              integration_params[:kind] = nil
            }

            specify do
              expect {
                post :create, :project_id => project.id, :integration => integration_params
              }.to change { Integration.count }.by(0)
              expect(response).to render_template('index')
            end

          end

          context "when save succeeds" do

            specify do
              post :create, :project_id => project.id, :integration => integration_params
              expect(flash[:notice]).to eq("#{integration.kind} was added to this project")
            end

          end
        end

        context "when integration exists" do
          before { integration.save }

          specify do
            expect {
              post :create, :project_id => project.id, :integration => integration_params
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
          delete :destroy, :project_id => project.id, :id => integration.id
          expect(response).to redirect_to(project_integrations_url(project))
        end

      end

    end

  end
end

