require 'rails_helper'

describe Admin::UsersController do

  context "when logged out" do
    %W[index].each do |action|
      specify do
        get action
        expect(response).to redirect_to(new_user_session_url)
      end
    end
    %W[edit update destroy].each do |action|
      specify do
        get action, id: 42
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  context "when logged in as admin" do

    let(:user)      { create :user, :with_team_and_is_admin }

    before do
      sign_in user
      allow(subject).to receive_messages(current_user: user, current_team: user.teams.first)
    end

    describe "collection actions" do

      describe "#index" do

        specify do
          get :index
          expect(response).to be_success
          expect(assigns[:users]).to eq([user])
        end

      end

    end

    describe "member actions" do

      describe "#edit" do

        specify do
          get :edit, id: user.id
          expect(response).to be_success
          expect(assigns[:user]).to eq(user)
        end

      end

      describe "#update" do

        before do
          allow(user).to receive(:update_attributes).with({}) { true }
        end

        specify do
          put :update, id: user.id, user: {}
          expect(assigns[:user]).to eq(user)
        end

        context "when update succeeds" do

          specify do
            put :update, id: user.id, user: {}
            expect(response).to redirect_to(admin_users_path)
          end

        end

        context "when update fails" do

          before do
            allow(user).to receive(:update_attributes).with({}) { false }
          end

          specify do
            put :update, id: user.id, user: {}
            expect(response).to redirect_to(admin_users_path)
          end

        end

      end

      describe "#enrollment" do

        specify do
          patch :enrollment, id: user.id, is_admin: true
          expect(assigns[:user]).to eq(user)
        end

        context "when update succeeds" do

          specify do
            patch :enrollment, id: user.id, is_admin: true
            expect(response).to redirect_to(admin_users_path)
          end

        end

        context "when update fails" do

          specify do
            patch :enrollment, id: user.id, is_admin: true
            expect(response).to redirect_to(admin_users_path)
          end

        end

      end

      describe "#destroy" do

        specify do
          expect { delete :destroy, id: user.id }.to change{User.count}.by(-1)
          expect(response).to redirect_to(admin_users_path)
        end

      end

    end

  end


  context "when logged in as non-admin user" do

    let(:user)         { create :user, :with_team }

    before do
      sign_in user
      allow(subject).to receive_messages(current_user: user, current_team: user.teams.first)
    end

    describe "collection actions" do

      describe "#index" do

        specify do
          get :index
          expect(response).to be_success
          expect(assigns[:users]).to eq([])
        end

      end

      describe "member actions" do

        describe "#edit" do

          specify do
            get :edit, id: user.id
            expect(response.status).to eq(404)
          end

        end

        describe "#update" do

          specify do
            put :update, id: user.id, user: {}
            expect(response.status).to eq(404)
          end

        end

        describe "#enrollment" do

          specify do
            patch :enrollment, id: user.id, is_admin: true
            expect(response.status).to eq(404)
          end

        end

        describe "#destroy" do

          specify do
            delete :destroy, id: user.id
            expect(response.status).to eq(404)
          end

        end

      end
    end

  end

end

