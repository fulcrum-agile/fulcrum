require 'test_helper'

class NotesControllerTest < ActionController::TestCase
  def setup
    @user = Factory.create(:user)
    @project = Factory.create(:project, :users => [@user])
    @story = Factory.create(:story, :project => @project,
                            :requested_by => @user)
    @note = Factory.create(:note, :story => @story, :user => @user)
  end

  test "should create a note" do
    sign_in @user
    assert_difference 'Note.count' do
      post :create, :project_id => @project.to_param, :story_id => @story.to_param,
        :note => {:note => 'This is a test comment.'}
    end
    assert_equal @user, assigns(:note).user
    assert_equal @story, assigns(:story)
    assert_response :success
  end

  test "should create a note from xhr" do
    sign_in @user
    assert_difference 'Note.count' do
      post :create, :project_id => @project.to_param, :story_id => @story.to_param,
        :note => {:note => 'This is a test comment.'}
    end
    assert_equal @user, assigns(:note).user
    assert_equal @story, assigns(:story)
    assert_response :success
  end

  test "should destroy a note from xhr" do
    sign_in @user
    assert_difference 'Note.count', -1 do
      xhr :delete, :destroy, :project_id => @project.to_param, :story_id => @story.to_param,
        :id => @note.to_param
    end
  end
  
  test "should get a single note in js format" do
    sign_in @user
    get :show, :project_id => @project.to_param, :story_id => @story.to_param, :id => @note.to_param,
      :format => 'js'
    assert_equal @project, assigns(:project)
    assert_equal @story, assigns(:story)
    assert_equal @note, assigns(:note)
  end

  test "should get all stories in js format" do
    sign_in @user
    get :index, :project_id => @project.to_param, :story_id => @story.to_param, :format => 'js'
    assert_equal @project, assigns(:project)
    assert_equal @story, assigns(:story)
    assert_equal @story.notes, assigns(:notes)
  end
end
