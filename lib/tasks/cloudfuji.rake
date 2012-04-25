namespace :cloudfuji do
  desc "Run the initial setup for a Busido app. Copies config files and seeds db."
  task :install => :environment do
    user = User.first

    if user.nil?
      puts "Creating default user..."
      user = User.new
      user.email = "#{::Cloudfuji::Platform.name}@#{ENV['CLOUDFUJI_HOST']}"
      user.initials = ::Cloudfuji::Platform.name[0..1].upcase
      user.name = ::Cloudfuji::Platform.name
      user.ido_id = "temporary_user"
      user.save!
    end

    project = Project.first

    if project.nil?
      puts "Creating default project..."
      project = Project.new
      project.name = "Default Project"
      project.point_scale = "fibonacci"
      project.start_date = Date.today
      project.iteration_start_day = 1
      project.iteration_length = 1
      project.created_at = Time.now
      project.updated_at = Time.now
      project.default_velocity = 10
      project.save!
    end
  end
end
