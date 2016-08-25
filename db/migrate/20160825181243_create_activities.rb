class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :project, null: false
      t.references :user, null: false
      t.integer :subject_id
      t.string :subject_type
      t.string :action
      t.text :subject_changes, default: nil

      t.timestamps
    end
    add_index :activities, [:project_id]
    add_index :activities, [:user_id]
    add_index :activities, [:project_id, :user_id]
  end
end
