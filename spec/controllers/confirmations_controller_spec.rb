require 'spec_helper'

describe ConfirmationsController do

  let(:user)  { mock_model(User) }

  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  describe "#show" do

    context "when token is invalid" do
      specify do
        get :show, :confirmation_token => "abc"
        response.should redirect_to(new_user_confirmation_path)
      end
    end

    context "when token is invalid" do

      before do
        user.stub(:valid? => true)
        user.stub(:reset_password_token => '123')
        user.stub(:set_reset_password_token => '123')
        User.stub(:confirm_by_token).with('abc').and_return(user)
      end

      specify do
        get :show, :confirmation_token => "abc"
        response.should redirect_to(edit_user_password_path(
          :reset_password_token => user.reset_password_token
        ))
      end
    end
  end

  describe "#new" do

    specify do
      get :new
      response.should be_success
    end

  end

  describe "#create" do

    context "when user is invalid" do
      specify do
        post :create, :user => {}
        response.should be_success
      end
    end

    context "when user is valid" do

      before do
        User.stub(:send_confirmation_instructions).with({}).and_return(user)
      end

      specify do
        post :create, :user => {}
        response.should redirect_to(new_user_session_path)
      end
    end

  end

end
