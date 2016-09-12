class MoveDisableRegistrationToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :disable_registration, :boolean, null: false, default: false
    add_column :teams, :registration_domain_whitelist, :string
    add_column :teams, :registration_domain_blacklist, :string
  end
end
