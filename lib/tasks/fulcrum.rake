namespace :fulcrum do
  desc "Set up database yaml."
  task :setup do
    example_file = Rails.root.join('config',"database.yml.example")
    file    = Rails.root.join('config',"database.yml")

    unless File.exists?(file)
      sh "cp #{example_file} #{file}"
    else
      puts "#{file} already exists!"
    end
  end
end
