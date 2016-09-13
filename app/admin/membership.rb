ActiveAdmin.register Membership do
  menu parent: 'Relationships'

  controller do
    belongs_to :project, optional: true
    belongs_to :user, optional: true

    def scoped_collection
      if params[:project_id]
        super.includes(:user)
      elsif params[:user_id]
        super.includes(:project)
      else
        super.includes(:user, :project)
      end
    end
  end


  permit_params :user_id, :project_id

  index do
    selectable_column
    id_column
    column do |m|
      m.user.name
    end
    column do |m|
      m.project.name
    end
  end

  show do
    attributes_table do
      row :user do
        resource.user.name
      end
      row :project do
        resource.project.name
      end
    end
  end

  config.filters = false

  form do |f|
    f.inputs "Membership Details" do
      f.input :user, as: :select,
        collection: User.order(:name).all
      f.input :project, as: :select,
        collection: Project.order(:name).all
    end
  end
end
