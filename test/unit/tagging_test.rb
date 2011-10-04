require 'test_helper'

class TaggingTest < ActiveSupport::TestCase
  def setup
    @user = Factory.create(:user)
    @project = Factory.create(:project, :users => [@user])
    @story = Factory.create(:story, :project => @project,
                            :requested_by => @user)
    @tagging = Factory.create(:tagging, :story => @story)
  end

  test "should not save without a story" do
    @tagging.story = nil
    assert !@tagging.save
  end

  test "should not save without a tag" do
    @tagging.tag = nil
    assert !@tagging.save
  end
end
