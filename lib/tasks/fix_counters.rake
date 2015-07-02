desc 'Fix the cache counters'
task :fix_counters => :environment do
  Project.find_each do |p|
    p.update_attributes(stories_count: p.stories.count, memberships_count: p.users.count)
  end
  User.find_each do |u|
    u.update_attributes(memberships_count: u.projects.count)
  end
end
