ActiveAdmin.register ApiToken do
  permit_params :team_id

  controller do
    def scoped_collection
      super.includes(:team)
    end
  end

  index do
    selectable_column
    column :team do |a|
      a.team&.name
    end
    column :token
    actions
  end

  filter :team
  filter :token

  actions :index, :new, :create, :destroy

  form do |f|
    f.inputs "API Token Details" do
      f.input :team, as: :select,
        collection: Team.order(:name).all
    end
    f.actions
  end
end
