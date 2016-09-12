desc "Create the first team of the system and move users and projects over"
task first_team: :environment do
  unless Team.count.zero?
    puts "Warning: only run this task once, it will only run if there is not team in the system yet"
    exit 1
  end

  if ENV['FIRST_TEAM_NAME'].nil?
    puts "Set the FIRST_TEAM_NAME environment variable for the team name"
    exit 1
  end

  if ENV['FIRST_TEAM_ADMIN_EMAIL'].nil?
    puts "Set the FIRST_TEAM_ADMIN_EMAIL environment variable for the first team administrator"
    exit 1
  end

  team = Team.create(name: ENV['FIRST_TEAM_NAME'])

  users = User.all.pluck(:id)
  users.each do |user_id|
    Enrollment.create(team_id: team.id, user_id: user_id, is_admin: false)
  end

  projects = Project.all.pluck(:id)
  projects.each do |project_id|
    Ownership.create(team_id: team.id, project_id: project_id, is_owner: true)
  end

  user = User.find_by_email(ENV['FIRST_TEAM_ADMIN_EMAIL'])
  user.enrollments.first.update_attributes(is_admin: true)

  puts "Team #{team.name} with slug #{team.slug} was successfully created."
  puts "Enrolled #{users.size} users to the team."
  puts "Ownership of #{projects.size} projects set to the team."
  puts "User #{user.name} set as the team administrator."
end
