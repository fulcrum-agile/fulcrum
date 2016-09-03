require 'rails_helper'

describe UsersController do

  let(:project) { create(:project) }

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

    let(:user)  { create(:user, is_admin: true) }

    before do
      project.users << user
      sign_in user
      allow(subject).to receive_messages(current_user: user)
    end

    describe "collection actions" do

      describe "#index" do

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
            expect(response.body).to eq(project.users.to_json)
          end

        end

      end

      describe "#create" do

        let(:user_params) {{
          "email"     => "user@example.com",
          "name"      => "Test User",
          "initials"  => "TU",
          "username"  => "test_user"
        }}

        specify do
          post :create, project_id: project.id, user: user_params
          expect(assigns[:project]).to eq(project)
          expect(response).to redirect_to(project_users_url(project))
        end

        context "when user does not exist" do

          specify do
            post :create, project_id: project.id, user: user_params
            expect(assigns[:user].name).to eq(user_params["name"])
            expect(assigns[:user].initials).to eq(user_params["initials"])
            expect(assigns[:user].was_created).to be true
            expect(response).to redirect_to(project_users_url(project))
          end

          context "when save fails" do

            before do
              user_params['email'] = nil
            end

            specify do
              post :create, project_id: project.id, user: user_params
              expect(response).to render_template('index')
            end

          end
        end

        context "when user exists" do

          before do
            create(:user, user_params)
          end

          specify do
            post :create, project_id: project.id, user: user_params
            expect(assigns[:user].was_created).to be_falsey
          end
        end

        context "when user is already a project member" do

          before do
            project.users << create(:user, user_params)
          end

          specify do
            post :create, project_id: project.id, user: user_params
            expect(flash[:alert]).to eq("#{assigns[:user].email} is already a member of this project")
          end
        end

        context "when user is not already a project member" do

          context "and user was created" do

            specify do
              post :create, project_id: project.id, user: user_params
              expect(flash[:notice]).to eq("#{assigns[:user].email} was sent an invite to join this project")
            end
          end

          context "and user already existed" do

            before do
              create(:user, user_params)
            end

            specify do
              post :create, project_id: project.id, user: user_params
              expect(flash[:notice]).to eq("#{assigns[:user].email} was added to this project")
            end
          end
        end
      end
    end

    describe "member actions" do

      describe "#destroy" do

        specify do
          delete :destroy, project_id: project.id, id: user.id
          expect(response).to redirect_to(project_users_url(project))
        end

      end

    end

  end
end
