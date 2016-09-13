ActiveAdmin.register Ownership do
  menu parent: 'Relationships'

  controller do
    belongs_to :project, optional: true
    belongs_to :team, optional: true

    def scoped_collection
      if params[:project_id]
        super.includes(:team)
      elsif params[:team_id]
        super.includes(:project)
      else
        super.includes(:team, :project)
      end
    end
  end

  permit_params :user_id, :team_id, :is_owner

  index do
    selectable_column
    id_column
    column do |o|
      o.team.name
    end
    column do |o|
      o.project.name
    end
    column :is_owner
  end

  show do
    attributes_table do
      row :team do
        resource.team.name
      end
      row :project do
        resource.project.name
      end
      row :is_owner
    end
  end

  filter :is_owner

  form do |f|
    f.inputs "Ownership Details" do
      f.input :team, as: :select,
        collection: Team.order(:name).all
      f.input :project, as: :select,
        collection: Project.order(:name).all
      f.input :is_owner, as: :check_boxes
    end
  end
end
