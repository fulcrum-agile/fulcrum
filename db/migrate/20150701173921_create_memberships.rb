class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.references :project, index: true
      t.references :user, index: true

      t.timestamps
    end
    add_index :memberships, [:project_id, :user_id], unique: true

    execute "insert into memberships (project_id, user_id) select project_id, user_id from projects_users"
    drop_table :projects_users

    add_column :projects, :stories_count, :integer, :default => 0
    add_column :projects, :memberships_count, :integer, :default => 0
    add_column :users, :memberships_count, :integer, :default => 0

    Project.find_each do |p|
      p.update_attributes(stories_count: p.stories.count, memberships_count: p.users.count)
    end
    User.find_each do |u|
      u.update_attributes(memberships_count: u.projects.count)
    end
  end

  def self.down
    create_table :projects_users do |t|
      t.references :project, index: true
      t.references :user, index: true
    end

    execute "insert into projects_users (project_id, user_id) select project_id, user_id from memberships"
    drop_table :memberships

    remove_column :projects, :stories_count
    remove_column :projects, :memberships_count
    remove_column :users, :memberships_count
  end
end
