class AddDefaultVelocityToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :default_velocity, :integer, :default => 10
  end

  def self.down
    remove_column :projects, :default_velocity
  end
end
