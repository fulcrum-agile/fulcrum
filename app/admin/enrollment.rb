ActiveAdmin.register Enrollment do
  menu parent: 'Relationships'

  controller do
    belongs_to :team, optional: true
    belongs_to :user, optional: true

    def scoped_collection
      if params[:team_id]
        super.includes(:user)
      elsif params[:user_id]
        super.includes(:team)
      else
        super.includes(:team, :user)
      end
    end
  end

  permit_params :team_id, :user_id, :is_admin

  index do
    selectable_column
    id_column
    column do |e|
      e.user.name
    end
    column do |e|
      e.team.name
    end
    column :is_admin
  end

  show do
    attributes_table do
      row :user do
        resource.user.name
      end
      row :team do
        resource.team.name
      end
      row :is_admin
    end
  end

  filter :is_admin

  form do |f|
    f.inputs "Enrollment Details" do
      f.input :user, as: :select,
        collection: User.order(:name).all
      f.input :team, as: :select,
        collection: Team.order(:name).all
      f.input :is_admin, as: :check_boxes
    end
  end
end
