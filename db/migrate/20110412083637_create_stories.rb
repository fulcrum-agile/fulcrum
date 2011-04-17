class CreateStories < ActiveRecord::Migration
  def self.up
    create_table :stories do |t|
      t.string :title
      t.text :description
      t.integer :estimate
      t.string :story_type, :default => 'feature'
      t.string :state, :default => 'unstarted'
      t.date :accepted_at
      t.integer :requested_by_id
      t.integer :owned_by_id
      t.references :project

      t.timestamps
    end
  end

  def self.down
    drop_table :stories
  end
end
