class AddKeys < ActiveRecord::Migration
  def up
    # clean up
    Story.where("project_id not in (?)", Project.all.pluck(:id)).delete_all
    Note.where("story_id not in (?)", Story.all.pluck(:id)).delete_all
    Task.where("story_id not in (?)", Story.all.pluck(:id)).delete_all

    add_foreign_key "integrations", "projects", name: "integrations_project_id_fk", dependent: :delete
    add_foreign_key "memberships", "projects", name: "memberships_project_id_fk", dependent: :delete
    add_foreign_key "memberships", "users", name: "memberships_user_id_fk", dependent: :delete
    add_foreign_key "notes", "stories", name: "notes_story_id_fk", dependent: :delete
    add_foreign_key "stories", "projects", name: "stories_project_id_fk", dependent: :delete
    add_foreign_key "tasks", "stories", name: "tasks_story_id_fk", dependent: :delete
  end

  def down
    remove_foreign_key "integrations", name: "integrations_project_id_fk"
    remove_foreign_key "memberships", name: "memberships_project_id_fk"
    remove_foreign_key "memberships", name: "memberships_user_id_fk"
    remove_foreign_key "notes", name: "notes_story_id_fk"
    remove_foreign_key "stories", name: "stories_project_id_fk"
    remove_foreign_key "tasks", name: "tasks_story_id_fk"
  end
end
