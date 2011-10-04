require 'test_helper'

class TagTest < ActiveSupport::TestCase
  def setup
    @user = Factory.create(:user)
    @project = Factory.create(:project, :users => [@user])
    @story = Factory.create(:story, :project => @project,
                            :requested_by => @user)
    @tag = Factory.create(:tag)
  end

  test "should return name from to_s" do
    assert_equal @tag.name, @tag.to_s
  end

  test "should not save without a name" do
    @tag.name = ''
    assert !@tag.save
  end

  test "should not save without a project" do
    @tag.project = nil
    assert !@tag.save
  end

end
