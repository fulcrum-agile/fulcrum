class CreateEnrollments < ActiveRecord::Migration
  def up
    create_table :enrollments do |t|
      t.integer :team_id, null: false
      t.integer :user_id, null: false
      t.boolean :is_admin, null: false, default: false

      t.timestamps
    end
    add_foreign_key :enrollments, :teams, dependent: :delete
    add_foreign_key :enrollments, :users, dependent: :delete
    add_index :enrollments, [:team_id, :user_id], unique: true

    unless Rails.env.production?
      team = Team.find_by_slug('default-team')
      User.select(:id, :is_admin).find_each do |user|
        Enrollment.create(team_id: team.id, user_id: user.id, is_admin: user.is_admin)
      end
    end
  end

  def down
    remove_index :enrollments, [:team_id, :user_id]
    remove_foreign_key :enrollments, :teams
    remove_foreign_key :enrollments, :users
    drop_table :enrollments
  end
end
