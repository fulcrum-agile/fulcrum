require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @user = Factory.create(:user)
    @project = Factory.create(:project, :users => [@user])
  end

  test "should not get project users if not logged in" do
    get :index, :project_id => @project.to_param
    assert_redirected_to new_user_session_url
  end

  test "should get project users" do
    sign_in @user
    get :index, :project_id => @project.to_param
    assert_response :success
    assert_equal @project, assigns(:project)
    assert assigns(:user).new_record?
    assert_equal [@user], assigns(:users)
  end

  test "should not get other users project users" do
    user = Factory.create(:user)
    sign_in user
    get :index, :project_id => @project.to_param
    assert_response :missing
  end

  test "should add existing user as project member" do
    user = Factory.create(:user)
    sign_in @user

    # Because this user already exists, no new users should be created, but
    # the user should be added to the project users collection.
    assert_no_difference 'User.count' do
      post :create, :project_id => @project.to_param,
        :user => {:email => user.email}
    end
    assert_equal @project, assigns(:project)
    assert_equal user, assigns(:user)
    assert assigns(:project).users.include?(user)
    assert_equal "#{user.email} was added to this project", flash[:notice]
    assert_redirected_to project_users_path(@project)
  end

  test "should create a new user as project member" do
    sign_in @user

    assert_difference ['User.count', 'ActionMailer::Base.deliveries.size'] do
      post :create, :project_id => @project.to_param,
                    :user => {
                      :name => 'New User', :initials => 'NU',
                      :email => 'new_user@example.com'
                    }
      assert_not_nil assigns(:users)
      assert_equal @project, assigns(:project)
      assert_equal 'new_user@example.com', assigns(:user).email
      assert !assigns(:user).confirmed?
      assert assigns(:project).users.include?(assigns(:user))
      assert_equal "new_user@example.com was sent an invite to join this project",
        flash[:notice]
      assert_redirected_to project_users_path(@project)
    end
  end

  test "should not create a new invalid user as project member" do
    sign_in @user

    assert_no_difference ['User.count', 'ActionMailer::Base.deliveries.size'] do
      post :create, :project_id => @project.to_param,
                    :user => {
                      :email => 'new_user@example.com'
                    }
      assert_not_nil assigns(:users)
      assert_equal @project, assigns(:project)
      assert_equal 'new_user@example.com', assigns(:user).email
      assert_response :success
    end
  end

  test "should not add a user who is already a member" do
    user = Factory.create(:user)
    @project.users << user

    sign_in @user

    assert_no_difference '@project.users.count' do
      post :create, :project_id => @project.to_param,
        :user => {:email => user.email}
    end
    assert_equal "#{user.email} is already a member of this project",
      flash[:alert]
    assert_redirected_to project_users_path(@project)
  end

  test "should not create a user for someone elses project" do
    user = Factory.create(:user)
    sign_in user

    assert_no_difference ['User.count', 'ActionMailer::Base.deliveries.size'] do
      post :create, :project_id => @project.to_param,
        :user => {:email => 'new_user@example.com'}
    end

    assert_response :missing
  end

  test "should remove a project member" do
    user = Factory.create(:user)
    @project.users << user

    sign_in @user

    assert_difference '@project.users.count', -1 do
      delete :destroy, :project_id => @project.to_param,
        :id => user.id
    end
    assert_equal @project, assigns(:project)
    assert_equal user, assigns(:user)
    assert_redirected_to project_users_url(@project)
  end

end
