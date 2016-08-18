class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.references :story
      t.string :name
      t.boolean :done, default: false

      t.timestamps
    end
    add_index :tasks, :story_id
  end

  def self.down
    drop_table :tasks
  end
end
