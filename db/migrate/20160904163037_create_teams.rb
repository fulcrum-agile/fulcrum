class CreateTeams < ActiveRecord::Migration
  def up
    create_table :teams do |t|
      t.string :name, null: false
      t.string :slug
      t.string :logo
      t.datetime :archived_at

      t.timestamps
    end
    add_index :teams, :name, unique: true
    add_index :teams, :slug, unique: true

    unless Rails.env.production?
      Team.create(name: 'Default Team', slug: 'default-team')
    end
  end

  def down
    remove_index :teams, :name
    remove_index :teams, :slug
    drop_table :teams
  end
end
