class StoryObserver < ActiveRecord::Observer
  # Create a new changeset whenever the story is changed
  def after_save(story)
    story.changesets.create!
  end
end
