class AddNotifyPreference < ActiveRecord::Migration
  def self.up
    add_column :users, :email_delivery, :boolean, :default => true
    add_column :users, :email_acceptance, :boolean, :default => true
    add_column :users, :email_rejection, :boolean, :default => true
  end

  def self.down
    remove_column :users, :email_delivery
    remove_column :users, :email_acceptance
    remove_column :users, :email_rejection
  end
end
