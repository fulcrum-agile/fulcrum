class AddSlugToProject < ActiveRecord::Migration
  def change
    add_column :projects, :slug, :string
    add_index :projects, :slug, unique: true
  end
end
