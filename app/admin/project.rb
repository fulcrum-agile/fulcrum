ActiveAdmin.register Project do
  permit_params :name, :point_scale, :default_velocity, :start_date, :iteration_start_day, :iteration_length

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

end
