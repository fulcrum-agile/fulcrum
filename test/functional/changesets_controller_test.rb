require 'test_helper'

class ChangesetsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @project = FactoryGirl.create(:project, :users => [@user])
    @story = FactoryGirl.create(:story, :project => @project,
                            :requested_by => @user)
    @changeset = FactoryGirl.create(:changeset, :story => @story,
                                :project => @project)
  end

  test "should get all in json format" do
    sign_in @user
    get :index, :project_id => @project.to_param, :format => 'json'
    assert_response :success
    assert_equal @project.changesets, assigns(:changesets)
  end

  test "should get in json format with from and to params" do
    sign_in @user
    get :index, :project_id => @project.to_param, :format => 'json',
                :from => @changeset.id - 1, :to => @changeset.id
    assert_response :success
    assert_equal [@changeset], assigns(:changesets)
  end
end
