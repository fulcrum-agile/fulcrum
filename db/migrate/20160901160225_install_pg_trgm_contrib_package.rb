class InstallPgTrgmContribPackage < ActiveRecord::Migration
  def up
    execute "CREATE EXTENSION pg_trgm;"
  end

  def down
    execute "DROP EXTENSION pg_trgm;"
  end
end
