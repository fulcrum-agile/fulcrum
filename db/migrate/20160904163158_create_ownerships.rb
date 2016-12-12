class CreateOwnerships < ActiveRecord::Migration
  def up
    create_table :ownerships do |t|
      t.integer :team_id, null: false
      t.integer :project_id, null: false
      t.boolean :is_owner, null: false, default: false

      t.timestamps
    end
    add_foreign_key :ownerships, :teams, dependent: :delete
    add_foreign_key :ownerships, :projects, dependent: :delete
    add_index :ownerships, [:team_id, :project_id], unique: true

    unless Rails.env.production?
      team = Team.find_by_slug('default-team')
      Project.find_each do |project|
        Ownership.create(team_id: team.id, project_id: project.id, is_owner: true)
      end
    end
  end

  def down
    remove_index :ownerships, [:team_id, :project_id]
    remove_foreign_key :ownerships, :teams
    remove_foreign_key :ownerships, :projects
    drop_table :ownerships
  end
end
