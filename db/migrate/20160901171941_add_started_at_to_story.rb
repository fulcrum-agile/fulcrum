class AddStartedAtToStory < ActiveRecord::Migration
  def change
    add_column :stories, :started_at, :datetime
    add_column :stories, :cycle_time, :float, default: 0.0
    change_column :stories, :accepted_at, :datetime
  end
end
