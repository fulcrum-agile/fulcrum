class AddNameAndInitialsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :name, :string
    add_column :users, :initials, :string
  end

  def self.down
    remove_column :users, :initials
    remove_column :users, :name
  end
end
