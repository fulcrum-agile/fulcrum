class AddDeadlineToStory < ActiveRecord::Migration
  def change
    add_column :stories, :deadline, :date

  end
end
