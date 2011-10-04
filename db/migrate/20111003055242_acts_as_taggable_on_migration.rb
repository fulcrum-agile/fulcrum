class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :name
      t.references :project
    end

    create_table :taggings do |t|
      t.references :tag
      t.references :story
    end

    add_index :taggings, :tag_id
    add_index :taggings, :story_id
  end

  def self.down
    drop_table :taggings
    drop_table :tags
  end
end
