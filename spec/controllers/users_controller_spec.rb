require 'rails_helper'

describe UsersController do

  let(:project) { mock_model(Project) }

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
    let(:users) { [user] }

    before do
      sign_in user
      allow(subject).to receive_messages(:current_user => user)
      allow(user).to receive_messages(:projects => projects)
      allow(projects).to receive_message_chain(:friendly, :find).with(project.id.to_s) { project }
      allow(project).to receive_messages(:users => users)
    end

    describe "collection actions" do

      describe "#index" do

        context "as html" do
          specify do
            get :index, :project_id => project.id
            expect(response).to be_success
            expect(assigns[:project]).to eq(project)
          end
        end

        context "as json" do
          specify do
            xhr :get, :index, :project_id => project.id, :format => :json
            expect(response).to be_success
            expect(response.body).to eq(users.to_json)
          end

        end

      end

      describe "#create" do

        let(:user_params) {{
          "email"     => "user@example.com",
          "name"      => "Test User",
          "initials"  => "TU"
        }}

        before do
          allow(User).to receive(:find_or_create_by).with(email: user_params["email"]) { user }
        end

        specify do
          post :create, :project_id => project.id, :user => user_params
          expect(assigns[:project]).to eq(project)
          expect(response).to redirect_to(project_users_url(project))
        end

        context "when user does not exist" do

          before do
            allow(user).to receive_messages(:new_record? => true)
            allow(user).to receive_messages(:save => true)
            allow(User).to receive(:find_or_create_by).with(email: user_params["email"]).and_yield(user).and_return(user)
          end

          specify do
            post :create, :project_id => project.id, :user => user_params
            expect(user.name).to eq(user_params["name"])
            expect(user.initials).to eq(user_params["initials"])
            expect(user.was_created).to be true
            expect(response).to redirect_to(project_users_url(project))
          end

          context "when save fails" do

            before do
              allow(user).to receive_messages(:save => false)
            end

            specify do
              post :create, :project_id => project.id, :user => user_params
              expect(response).to render_template('index')
            end

          end
        end

        context "when user exists" do

          before do
            allow(user).to receive_messages(:new_record? => false)
            allow(User).to receive(:find_or_create_by).with(email: user_params["email"]) { user }
          end

          specify do
            post :create, :project_id => project.id, :user => user_params
            expect(user.was_created).to be_falsey
          end
        end

        context "when user is already a project member" do

          before do
            allow(users).to receive(:include?).with(user) { true }
          end

          specify do
            post :create, :project_id => project.id, :user => user_params
            expect(flash[:alert]).to eq("#{user.email} is already a member of this project")
          end
        end

        context "when user is not already a project member" do

          before do
            allow(users).to receive(:include?).with(user) { false }
          end

          context "and user was created" do
            before { allow(user).to receive(:was_created) { true } }
            specify do
              post :create, :project_id => project.id, :user => user_params
              expect(flash[:notice]).to eq("#{user.email} was sent an invite to join this project")
            end
          end
          context "and user already existed" do
            before { allow(user).to receive(:was_created) { false } }
            specify do
              post :create, :project_id => project.id, :user => user_params
              expect(flash[:notice]).to eq("#{user.email} was added to this project")
            end
          end
        end
      end
    end

    describe "member actions" do

      describe "#destroy" do

        before do
          allow(users).to receive(:find).with(user.id.to_s) { user }
          expect(users).to receive(:delete).with(user)
        end

        specify do
          delete :destroy, :project_id => project.id, :id => user.id
          expect(response).to redirect_to(project_users_url(project))
        end

      end

    end

  end
end
