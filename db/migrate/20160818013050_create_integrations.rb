class CreateIntegrations < ActiveRecord::Migration
  def change
    enable_extension "hstore"

    create_table :integrations do |t|
      t.belongs_to :project, foreign_key: true
      t.string :kind, null: false
      t.hstore :data, null: false

      t.timestamps
    end
    add_index  :integrations, :data, using: :gin
  end
end
