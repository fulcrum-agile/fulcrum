require 'spec_helper'

describe RegistrationsController do

  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe "disable registration" do
    before do
      Configuration.for('fulcrum') do
        disable_registration true
      end
    end

    describe "#new" do
      specify do
        get :new
        response.status.should eq 404
      end
    end

    describe "#create" do
      specify do
        post :create, :user => {:name => 'Test User', :initials => 'TU', :email => 'test_user@example.com'}
        response.status.should eq 404
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
        response.status.should eq 200
      end
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
end
