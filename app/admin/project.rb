ActiveAdmin.register Project do
  permit_params :name, :point_scale, :default_velocity, :start_date, :iteration_start_day, :iteration_length, :archived_at, :user_ids

  index do
    selectable_column
    id_column
    column :name
    column :point_scale
    column :default_velocity
    column :start_date
    column :iteration_start_day
    column :iteration_length
    column :archived_at
  end

  show do
    attributes_table do
      row :name
      row :point_scale
      row :default_velocity
      row :start_date
      row :iteration_start_day
      row :iteration_length
      row :archived_at
      table_for resource.users.order(:name) do
        column 'Members' do |user|
          link_to user.name, manage_user_path(user)
        end
      end
    end
  end

  filter :name
  filter :start_date
  filter :archived_at

  form do |f|
    f.inputs "Project Details" do
      f.input :name
      f.input :point_scale
      f.input :default_velocity
      f.input :start_date
      f.input :iteration_start_day
      f.input :iteration_length
      f.input :archived_at
    end
    f.actions
  end

  sidebar "Project Details", only: [:show, :edit] do
    ul do
      li link_to "Memberships", manage_project_memberships_path(resource)
      li link_to "Ownerships", manage_project_ownerships_path(resource)
    end
  end

end
