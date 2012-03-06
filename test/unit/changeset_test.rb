require 'test_helper'

class ChangesetTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @project = FactoryGirl.create(:project, :users => [@user])
    @story = FactoryGirl.create(:story, :project => @project,
                            :requested_by => @user)
    @changeset = FactoryGirl.create(:changeset, :story => @story,
                                :project => @project)
  end

  test "should not save without a story" do
    @changeset.story = nil
    assert !@changeset.save
  end

  test "should determine project from story" do
    # If project is not set, it can be inferred from story.project
    @changeset.project = nil
    assert @changeset.save!
    assert_equal @project, @changeset.project
  end

  test "should get changesets since a given id" do
    assert_equal 'id > 234', Changeset.since(234).where_values.first
  end
end
