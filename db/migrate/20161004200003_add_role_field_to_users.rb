class AddRoleFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :role, :string, null: false, default: 'developer'
  end
end
