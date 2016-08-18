class AddArchivedAtFieldToProject < ActiveRecord::Migration
  def change
    add_column :projects, :archived_at, :datetime, default: nil
  end
end
