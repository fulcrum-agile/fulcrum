require 'rails_helper'

describe TeamsController, type: :controller do
  let(:user) { create :user, :with_team_and_is_admin }
  let!(:team) { user.teams.first }

  context "when logged out" do
    specify do
      get :new
      expect(response).to render_template('new')
    end

    %W[edit update destroy].each do |action|
      specify do
        get action, id: 42
        expect(response).to redirect_to(new_user_session_url)
      end
    end

    describe "#switch" do
      it "must set team_slug session" do
        get :switch, id: team.slug
        expect(session[:team_slug]).to eq(team.slug)
      end
    end

    describe "#create" do

      let(:team_params) {{ "name" => "Test Team"}}

      specify do
        post :create, team: team_params
        expect(assigns[:team].name).to eq(team_params["name"])
      end

      context "when save succeeds" do

        specify do
          post :create, team: team_params
          expect(response).to redirect_to(root_path)
          expect(flash[:notice]).to eq(I18n.t('teams.team was successfully created'))
        end
      end

      context "when save fails" do

        specify do
          post :create, team: { name: nil }
          expect(response).to be_success
          expect(response).to render_template('new')
        end
      end
    end
  end

  context "when logged in" do
    context "as admin" do
      before do
        sign_in user
        allow(subject).to receive_messages(current_user: user, current_team: user.teams.first)
      end

      describe "#switch" do
        it "must set the current_team_slug session" do
          get :switch, id: team.slug
          expect(session[:current_team_slug]).to eq(team.slug)
        end
      end

      describe "#edit" do

        specify do
          get :edit, id: 'xyz'
          expect(response).to be_success
          expect(assigns[:team]).to eq(team)
        end
      end

      describe "#update" do

        let(:team_params) { { name: 'New Team Name' } }

        specify do
          put :update, id: 'xyz', team: team_params
          expect(assigns[:team].name).to eq('New Team Name')
        end

        context "when update succeeds" do

          specify do
            put :update, id: 'xyz', team: team_params
            expect(response).to be_success
            expect(response).to render_template('edit')
          end
        end

        context "when update fails" do

          before { create :team, name: 'Team Hello' }
          specify do
            put :update, id: 'xyz', team: { name: 'Team Hello' }
            expect(response).to be_success
            expect(response).to render_template('edit')
          end

          context 'when name is empty' do
            specify do
              put :update, id: 'xyz', team: { name: '' }
              expect(response).to be_success
              expect(response).to render_template('edit')
            end
          end
        end
      end

      describe "#destroy" do

        specify do
          delete :destroy, id: 'xyz'
          expect(assigns[:team].archived_at).to_not be_nil
          expect(session[:current_team_slug]).to be_nil
          expect(response).to redirect_to(root_path)
        end
      end
    end

    context "as normal user" do
      let(:normal_user) { create :user, teams: [team] }

      before do
        sign_in normal_user
        allow(subject).to receive_messages(current_user: normal_user, current_team: normal_user.teams.first)
      end

      describe "#edit" do
        specify do
          get :edit, id: 'xyz'
          expect(response).to_not be_success
          expect(response).to redirect_to(root_path)
        end
      end

      describe "#update" do
        specify do
          put :update, id: 'xyz', team: { name: 'New Team Test'}
          expect(response).to_not be_success
          expect(response).to redirect_to(root_path)
        end
      end

      describe "#destroy" do
        specify do
          delete :destroy, id: 'xyz'
          expect(response).to_not be_success
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end
