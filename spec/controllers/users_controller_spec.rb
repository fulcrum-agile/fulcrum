require 'spec_helper'

describe UsersController do

  let(:project) { mock_model(Project) }

  context "when logged out" do
    %w[index create].each do |action|
      specify do
        get action, :project_id => project.id
        response.should redirect_to(new_user_session_url)
      end
    end
    %w[destroy].each do |action|
      specify do
        get action, :id => 42, :project_id => project.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  context "when logged in" do

    let(:user)  { FactoryGirl.create(:user) }
    let(:projects)  { double("projects") }
    let(:users) { [user] }

    before do
      sign_in user
      subject.stub(:current_user => user)
      user.stub(:projects => projects)
      projects.stub(:find).with(project.id.to_s) { project }
      project.stub(:users => users)
    end

    describe "collection actions" do

      describe "#index" do

        context "as html" do
          specify do
            get :index, :project_id => project.id
            response.should be_success
            assigns[:project].should == project
            assigns[:users].should == users
          end
        end

        context "as json" do
          specify do
            xhr :get, :index, :project_id => project.id, :format => :json
            response.should be_success
            response.body.should == users.to_json
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
          User.stub(:find_or_create_by_email).with(user_params["email"]) { user }
        end

        specify do
          post :create, :project_id => project.id, :user => user_params
          assigns[:project].should == project
          assigns[:users].should == users
        end

        context "when user does not exist" do

          before do
            user.stub(:new_record? => true)
            user.stub(:save => true)
            User.stub(:find_or_create_by_email).with(user_params["email"]).and_yield(user).and_return(user)
          end

          specify do
            post :create, :project_id => project.id, :user => user_params
            user.name.should == user_params["name"]
            user.initials.should == user_params["initials"]
            user.was_created.should be_true
            response.should redirect_to(project_users_url(project))
          end

          context "when save fails" do

            before do
              user.stub(:save => false)
            end

            specify do
              post :create, :project_id => project.id, :user => user_params
              response.should render_template('index')
            end

          end
        end

        context "when user exists" do

          before do
            user.stub(:new_record? => false)
            User.stub(:find_or_create_by_email).with(user_params["email"]) { user }
          end

          specify do
            post :create, :project_id => project.id, :user => user_params
            user.was_created.should be_false
          end
        end

        context "when user is already a project member" do

          before do
            users.stub(:include?).with(user) { true }
          end

          specify do
            post :create, :project_id => project.id, :user => user_params
            flash[:alert].should == "#{user.email} is already a member of this project"
          end
        end

        context "when user is not already a project member" do

          before do
            users.stub(:include?).with(user) { false }
          end

          context "and user was created" do
            before { user.stub(:was_created) { true } }
            specify do
              post :create, :project_id => project.id, :user => user_params
              flash[:notice].should == "#{user.email} was sent an invite to join this project"
            end
          end
          context "and user already existed" do
            before { user.stub(:was_created) { false } }
            specify do
              post :create, :project_id => project.id, :user => user_params
              flash[:notice].should == "#{user.email} was added to this project"
            end
          end
        end
      end
    end

    describe "member actions" do

      describe "#destroy" do

        before do
          users.stub(:find).with(user.id.to_s) { user }
          users.should_receive(:delete).with(user)
        end

        specify do
          delete :destroy, :project_id => project.id, :id => user.id
          response.should redirect_to(project_users_url(project))
        end

      end

    end

  end
end
