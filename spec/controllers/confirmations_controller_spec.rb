require 'rails_helper'

describe ConfirmationsController do

  let(:user)  { mock_model(User) }

  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  describe "#show" do

    context "when token is invalid" do
      specify do
        get :show, :confirmation_token => "abc"
        expect(response).to redirect_to(new_user_confirmation_path)
      end
    end

    context "when token is invalid" do

      before do
        allow(user).to receive_messages(:valid? => true)
        allow(user).to receive_messages(:reset_password_token => '123')
        allow(user).to receive_messages(:set_reset_password_token => '123')
        allow(User).to receive(:confirm_by_token).with('abc').and_return(user)
      end

      specify do
        get :show, :confirmation_token => "abc"
        expect(response).to redirect_to(edit_user_password_path(
          :reset_password_token => user.reset_password_token
        ))
      end
    end
  end

  describe "#new" do

    specify do
      get :new
      expect(response).to be_success
    end

  end

  describe "#create" do

    context "when user is invalid" do
      specify do
        post :create, :user => {}
        expect(response).to be_success
      end
    end

    context "when user is valid" do

      before do
        allow(User).to receive(:send_confirmation_instructions).with({}).and_return(user)
      end

      specify do
        post :create, :user => {}
        expect(response).to redirect_to(new_user_session_path)
      end
    end

  end

end
