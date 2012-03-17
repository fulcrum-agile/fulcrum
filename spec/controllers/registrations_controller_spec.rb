require 'spec_helper'

describe RegistrationsController do

  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe "#create" do
    specify do
      post :create, :user => {:name => 'Test User', :initials => 'TU', :email => 'test_user@example.com'}
      response.should redirect_to(new_user_session_path)
    end
    specify do
      post :create, :user => {:name => 'Test User', :initials => 'TU', :email => 'test_user@example.com'}
      flash[:notice].should == 'You have signed up successfully. A confirmation was sent to your e-mail. Please follow the contained instructions to activate your account.'
    end
  end

end
