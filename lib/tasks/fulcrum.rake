namespace :fulcrum do
  desc "Set up database yaml."
  task :setup do
    example_database_config = Rails.root.join('config',"database.yml.example")
    database_config = Rails.root.join('config',"database.yml")

    unless File.exists?(database_config)
      cp example_database_config, database_config
    else
      puts "#{database_config} already exists!"
    end
  end
end
