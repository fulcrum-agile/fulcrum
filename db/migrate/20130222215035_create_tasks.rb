class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.references :story
      t.string :task
      t.boolean :done, :default => false

      t.timestamps
    end
    add_index :tasks, :story_id
  end
end
