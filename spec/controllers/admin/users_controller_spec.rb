require 'rails_helper'

describe Admin::UsersController do

  context "when logged out" do
    %W[index].each do |action|
      specify do
        get action
        response.should redirect_to(new_user_session_url)
      end
    end
    %W[edit update destroy].each do |action|
      specify do
        get action, :id => 42
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  context "when logged in" do

    let(:user)      { FactoryGirl.create :user }

    before do
      sign_in user
    end

    describe "collection actions" do

      describe "#index" do

        specify do
          get :index
          response.should be_success
          assigns[:users].should == User.all
        end

      end

    end

    describe "member actions" do

      describe "#edit" do

        specify do
          get :edit, :id => user.id
          response.should be_success
          assigns[:user].should == user
        end

      end

      describe "#update" do

        before do
          user.stub(:update_attributes).with({}) { true }
        end

        specify do
          put :update, :id => user.id, :user => {}
          assigns[:user].should == user
        end

        context "when update succeeds" do

          specify do
            put :update, :id => user.id, :user => {}
            response.should redirect_to(admin_users_path)
          end

        end

        context "when update fails" do

          before do
            user.stub(:update_attributes).with({}) { false }
          end

          specify do
            put :update, :id => user.id, :user => {}
            response.should redirect_to(admin_users_path)
          end

        end

      end

      describe "#destroy" do

        specify do
          expect { delete :destroy, :id => user.id }.to change{User.count}.by(-1)
          response.should redirect_to(admin_users_path)
        end

      end

    end

  end

end

