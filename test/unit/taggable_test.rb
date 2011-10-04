require 'test_helper'

class TaggableTest < ActiveSupport::TestCase
  def setup
    @user = Factory.create(:user)
    @project = Factory.create(:project, :users => [@user])
    @taggable = Factory.create(:story, :project => @project,
                            :requested_by => @user)
  end

  test "should attr_writer tag_string" do
    @taggable.tag_string = "fake tag"
    assert_equal @taggable.tag_string, "fake tag"
  end

  test "should create a single tag on save" do
    @taggable.tag_string = "single_tag"
    @taggable.save
    assert_equal @taggable.tags.length, 1
    assert_equal @taggable.tags.first.name, "single_tag"
  end

  test "should create multiple tags on save" do
    @taggable.tag_string = "multiple,tags"
    @taggable.save
    assert_equal @taggable.tags.length, 2
    assert_equal @taggable.tags.map(&:name), ["multiple", "tags"]
  end

  test "should strip whitespace" do
    @taggable.tag_string = "  strip ,  whitespace   "
    @taggable.save
    assert_equal @taggable.tags.length, 2
    assert_equal @taggable.tags.map(&:name), ["strip", "whitespace"]
  end

  test "should detect duplicates" do
    @taggable.tag_string = "duplicate, duplicate, tags"
    @taggable.save
    assert_equal @taggable.tags.length, 2
    assert_equal @taggable.tags.map(&:name), ["duplicate", "tags"]
  end

  test "should reject blanks" do
    @taggable.tag_string = "one, , tag"
    @taggable.save
    assert_equal @taggable.tags.length, 2
    assert_equal @taggable.tags.map(&:name), ["one", "tag"]
  end

  test "should not duplicate existing tags" do
    @taggable.tags.create(:name => "original", :project_id => @project.id)
    assert_equal @taggable.tags.count, 1
    @taggable.tag_string = "original, tags"
    @taggable.save
    assert_equal @taggable.tags.length, 2
    assert_equal @taggable.tags.map(&:name), ["original", "tags"]
  end

  test "should return tags as string" do
    @taggable.tags.create(:name => "bert", :project_id => @project.id)
    @taggable.tags.create(:name => "ernie", :project_id => @project.id)
    assert_equal @taggable.tag_string, "bert,ernie"
  end
end
