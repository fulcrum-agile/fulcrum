require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  def setup
    @user = Factory.create(:user)
    @project = Factory.create(:project, :users => [@user])
    @story = Factory.create(:story, :project => @project,
                            :requested_by => @user)
    @note = Factory.create(:note, :story => @story, :user => @user)
  end

  test "creating a note creates a changeset" do
    assert_difference ['Changeset.count', '@story.changesets.count'] do
      Factory.create(:note, :story => @story, :user => @user)
    end
  end
end
