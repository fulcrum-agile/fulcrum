ActiveAdmin.register Membership do
  controller do
    def find_resource
      scoped_collection.includes(:user, :project)
    end
  end

  belongs_to :project

  permit_params :user_id, :project_id

  index do
    selectable_column
    id_column
    column do |membership|
      membership.user.name
    end
    column do |membership|
      membership.project.name
    end
  end

  show do
    row 'Member' do
      resource.user.name
    end
    row 'Project' do
      resource.project.name
    end
  end

  config.filters = false

  form do |f|
    f.inputs "Membership Details" do
      f.input :user, as: :select,
        collection: Enrollment.where(team: resource.project.teams).includes(:user).map(&:user)
      f.input :project, as: :select,
        collection: Ownership.where(team: resource.project.teams).includes(:project).map(&:project)
    end
  end
end
