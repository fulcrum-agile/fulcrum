class AddPositionToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :position, :decimal
  end

  def self.down
    remove_column :stories, :position
  end
end
