require 'rails_helper'

describe RegistrationsController do

  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe "disable registration" do
    context "system level lock down" do
      before do
        Configuration.for('fulcrum') do
          disable_registration true
        end
      end

      after do
        Configuration.for('fulcrum') do
          disable_registration false
        end
      end

      describe "#new" do
        specify do
          get :new
          expect(response.status).to eq 404
        end
      end

      describe "#create" do
        specify do
          post :create, user: {name: 'Test User', initials: 'TU', email: 'test_user@example.com'}
          expect(response.status).to eq 404
        end
      end
    end

    context "team level allowed" do
      let!(:team) { create :team, disable_registration: false }

      before do
        session[:team_slug] = team.slug
      end

      describe "#new" do
        specify do
          get :new
          expect(response.status).to eq 200
        end
      end

      describe "#create" do
        specify do
          post :create, user: build(:unconfirmed_user).attributes
          expect(response).to redirect_to(new_user_session_path)
        end
        specify do
          post :create, user: build(:unconfirmed_user).attributes
          expect(flash[:notice]).to eq('You have signed up successfully. A confirmation was sent to your e-mail. Please follow the contained instructions to activate your account.')
        end
      end
    end
  end

  describe "enable registration" do
    before do
      Configuration.for('fulcrum') do
        disable_registration false
      end
    end

    describe "#new" do
      specify do
        get :new
        expect(response.status).to eq 200
      end
    end

    describe "#create" do
      specify do
        post :create, user: build(:unconfirmed_user).attributes
        expect(response).to redirect_to(new_user_session_path)
      end
      specify do
        post :create, user: build(:unconfirmed_user).attributes
        expect(flash[:notice]).to eq('You have signed up successfully. A confirmation was sent to your e-mail. Please follow the contained instructions to activate your account.')
      end
    end
  end
end
