class AddIndicesToStoriesAndNotes < ActiveRecord::Migration
  def self.up
    add_index :stories, :project_id
    add_index :notes, :story_id
  end

  def self.down
    remove_index :stories, :project_id
    remove_index :notes, :story_id
  end
end
