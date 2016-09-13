ActiveAdmin.register Team do
  permit_params :name, :disable_registration, :registration_domain_whitelist, :registration_domain_blacklist, :logo, :archived_at

  index do
    selectable_column
    id_column
    column :name
    column :disable_registration
    column :archived_at
  end

  filter :name
  filter :archived_at

  form do |f|
    f.inputs "Team Details" do
      f.input :name
      f.input :disable_registration
      f.input :registration_domain_whitelist
      f.input :registration_domain_blacklist
      f.input :archived_at
    end
    f.actions
  end

  sidebar "Team Details", only: [:show, :edit] do
    ul do
      li link_to "Ownerships", manage_team_ownerships_path(resource)
      li link_to "Memberships", manage_team_memberships_path(resource)
    end
  end
end
