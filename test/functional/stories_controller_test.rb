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
        :story => {:title => 'Test story', :requested_by_id => @user.to_param}
    end
    assert_equal @user, assigns(:story).requested_by
    assert_equal @project, assigns(:project)
    assert_redirected_to project_url(@project)
  end

  test "should create a story from xhr" do
    sign_in @user
    assert_difference 'Story.count' do
      xhr :post, :create, :project_id => @project.to_param,
        :story => {:title => 'Test title', :editing => true}
    end
    assert_equal @user, assigns(:story).requested_by
    assert_equal @project, assigns(:project)
    assert_response :success
  end

  test "should destroy a story from xhr" do
    sign_in @user
    assert_difference 'Story.count', -1 do
      xhr :delete, :destroy, :project_id => @project.to_param,
        :id => @story.to_param
    end
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

  test "should get a single story in js format" do
    sign_in @user
    get :show, :project_id => @project.to_param, :id => @story.to_param,
      :format => 'js'
    assert_equal @project, assigns(:project)
    assert_equal @story, assigns(:story)
  end

  test "should get all stories in js format" do
    sign_in @user
    get :index, :project_id => @project.to_param, :format => 'js'
    assert_equal @project, assigns(:project)
    assert_equal @project.stories, assigns(:stories)
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

  test "should get all stories in CSV format" do
    sign_in @user
    get :index, :project_id => @project.to_param, :format => 'csv'
    assert_equal @project, assigns(:project)
    assert_equal @project.stories, assigns(:stories)
    assert_equal 'text/csv',
      @response.headers['Content-Type'], 'Content type is CSV'
    assert_match /attachment; filename="Test Project-\d{8}_\d{4}\.csv"/,
      @response.headers['Content-Disposition'],
      "Filename should be 'Test Project-YYYYMMDD_HHMM.csv'"
    assert_equal @project.stories.count + 1, @response.body.lines.count,
      "body should have 1 header line plus 1 line for each story"
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

  test "should update a story via xhr" do
    sign_in @user
    xhr :put, :update, :id => @story.to_param, :project_id => @project.to_param,
      :story => {:title => "Updated title", :estimate => 1}
    assert_response :success
    assert_equal @project, assigns(:project)
    assert_equal @story, assigns(:story)
    assert_equal 1, assigns(:story).estimate
  end

  test "should show csv import form" do
    sign_in @user
    get :import, :project_id => @project.to_param
    assert_response :success
    assert_equal @project, assigns(:project)
  end

  test "should import a csv of stories" do
    sign_in @user
    csv = fixture_file_upload('csv/stories.csv')

    # Count of new stories should be number of lines in the csv minus the
    # header line
    story_count = File.readlines(csv.path).length - 1

    # The fixture CSV stories are all requested by and assigned to 'User 1',
    # so make sure this user is present and a member of the project
    assigned_user = Factory.create(:user, :name => 'Test User')
    @project.users << assigned_user

    assert_difference 'Story.count', story_count do
      post :import_upload, :project_id => @project.to_param, :csv => csv
    end

    assigns(:stories).each do |story|
      assert_equal assigned_user, story.requested_by
      assert_equal assigned_user, story.owned_by
    end

    assert_equal @project, assigns(:project)
    assert assigns(:project).suppress_notifications
    assert_equal story_count, assigns(:stories).length
    assert_equal "Imported %d stories" % story_count, flash[:notice]
    assert_nil flash[:alert]
    assert_response :success
    assert_template 'import'
  end

  test "should import a csv with some invalid rows" do
    sign_in @user
    csv = fixture_file_upload('csv/stories_invalid.csv')

    assert_difference 'Story.count', 1 do
      post :import_upload, :project_id => @project.to_param, :csv => csv
    end

    assert_equal @project, assigns(:project)
    assert_equal 1, assigns(:valid_stories).length
    assert_equal "Imported 1 story", flash[:notice]
    assert_equal 1, assigns(:invalid_stories).length
    assert_equal "1 story failed to import", flash[:alert]
    assert_response :success
    assert_template 'import'
  end

  test "should gracefully fail to import an illegal csv" do
    sign_in @user
    csv = fixture_file_upload('csv/stories_illegal.csv')

    assert_no_difference 'Story.count' do
      post :import_upload, :project_id => @project.to_param, :csv => csv
    end

    assert_equal @project, assigns(:project)
    assert_equal "Unable to import CSV: Illegal quoting on line 1.", flash[:alert]
    assert_response :success
    assert_template 'import'
  end

  test "should handle no file selected for import" do
    sign_in @user

    post :import_upload, :project_id => @project.to_param

    assert_equal @project, assigns(:project)
    assert_equal "You must select a file for import", flash[:alert]
    assert_response :success
    assert_template 'import'
  end

  test "should set the acting user" do
    sign_in @user
    put :update, :id => @story.to_param, :project_id => @project.to_param,
      :story => {:estimate => 1}
    assert_equal @user, assigns(:story).acting_user
  end

  private

  def assert_state_change(action, resulting_state)
    put action, :id => @story.to_param, :project_id => @project.to_param
    assert_equal @story, assigns(:story)
    assert_equal resulting_state, assigns(:story).state
    assert_redirected_to project_url(@project)
  end

end
