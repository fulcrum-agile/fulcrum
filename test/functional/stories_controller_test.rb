require 'test_helper'

class StoriesControllerTest < ActionController::TestCase
  def setup
    @user = Factory.create(:user)
    @project = Factory.create(:project, :users => [@user])
    @story = Factory.create(:story, :project => @project,
                            :requested_by => @user)
  end

  test "should create a story" do
    sign_in @user
    assert_difference 'Story.count' do
      post :create, :project_id => @project.to_param,
        :story => {:requested_by_id => @user.to_param}
    end
    assert_equal @user, assigns(:story).requested_by
    assert_equal @project, assigns(:project)
    assert_redirected_to project_url(@project)
  end

  test "should start a story" do
    sign_in @user
    assert_state_change(:start, 'started')
  end
  test "should finish a story" do
    sign_in @user
    @story.update_attribute :state, 'started'
    assert_state_change(:finish, 'finished')
  end
  test "should deliver a story" do
    sign_in @user
    @story.update_attribute :state, 'finished'
    assert_state_change(:deliver, 'delivered')
  end
  test "should accept a story" do
    sign_in @user
    @story.update_attribute :state, 'delivered'
    assert_state_change(:accept, 'accepted')
  end
  test "should reject a story" do
    sign_in @user
    @story.update_attribute :state, 'delivered'
    assert_state_change(:reject, 'rejected')
  end

  test "should get done stories in js format" do
    sign_in @user
    get :done, :project_id => @project.to_param, :format => 'js'
    assert_equal @project, assigns(:project)
    assert_equal @project.stories.done, assigns(:stories)
  end
  test "should get in progress stories in js format" do
    sign_in @user
    get :in_progress, :project_id => @project.to_param, :format => 'js'
    assert_equal @project, assigns(:project)
    assert_equal @project.stories.in_progress, assigns(:stories)
  end
  test "should get backlog stories in js format" do
    sign_in @user
    get :backlog, :project_id => @project.to_param, :format => 'js'
    assert_equal @project, assigns(:project)
    assert_equal @project.stories.backlog, assigns(:stories)
  end

  test "should estimate a story" do
    sign_in @user
    put :update, :id => @story.to_param, :project_id => @project.to_param,
      :story => {:estimate => 1}
    assert_equal @project, assigns(:project)
    assert_equal @story, assigns(:story)
    assert_equal 1, assigns(:story).estimate
    assert_redirected_to project_url(@project)
  end

  private

  def assert_state_change(action, resulting_state)
    put action, :id => @story.to_param, :project_id => @project.to_param
    assert_equal @story, assigns(:story)
    assert_equal resulting_state, assigns(:story).state
    assert_redirected_to project_url(@project)
  end

end
