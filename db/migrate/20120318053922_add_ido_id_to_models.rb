class AddIdoIdToModels < ActiveRecord::Migration
  def change
    add_column :notes,      :ido_id, :string
    add_column :projects,   :ido_id, :string
    add_column :stories,    :ido_id, :string
  end
end
