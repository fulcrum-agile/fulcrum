# Based on https://gist.github.com/fgrehm/4253885
namespace :deploy do
  PRODUCTION_APP = ENV.fetch('PRODUCTION_APP')
  STAGING_APP    = ENV.fetch('STAGING_APP')
  REMOTE         = ENV['REMOTE_HOST'] || 'git@heroku.com'
  GIT_OPTS       = ENV['GIT']
  BRANCH         = ENV['BRANCH'] || 'master'

  def heroku_cmd(cmd)
    Bundler.with_clean_env do
      sh "heroku #{cmd}"
    end
  end

  desc 'Deploy app to staging'
  task :staging => [:set_staging_app, :push, :tag]
  desc 'Rollback last deploy to staging'
  task :staging_rollback => [:set_staging_app, :off, :push_previous, :restart, :on]

  desc 'Deploy app to production'
  task :production => [:set_production_app, :push, :tag]
  desc 'Rollback last deploy to production'
  task :production_rollback => [:set_production_app, :off, :push_previous, :restart, :on]

  namespace :staging do
    desc 'Deploy app to staging and run migrations'
    task :full => [:set_staging_app, :off, :push, :migrate, :restart, :on, :tag]
  end

  namespace :production do
    desc 'Deploy app to production and run migrations'
    task :full => [:set_production_app, :off, :push, :migrate, :restart, :on, :tag]
  end


  task :set_staging_app do
    APP = STAGING_APP
  end

  task :set_production_app do
    APP = PRODUCTION_APP
  end

  task :push do
    puts 'Deploying site to Heroku ...'
    sh "git push #{GIT_OPTS} #{REMOTE}:#{APP}.git #{BRANCH}:master"
  end

  task :restart do
    puts 'Restarting app servers ...'
    heroku_cmd "restart --app #{APP}"
  end

  task :tag do
    release_name = "#{APP}_release-#{Time.now.utc.strftime("%Y%m%d%H%M%S")}"
    puts "Tagging release as '#{release_name}'"
    sh "git tag -a #{release_name} -m 'Tagged release'"
    sh "git push origin --tags"
    sh "git push --tags #{REMOTE}:#{APP}.git"
  end

  task :migrate do
    puts 'Running database migrations ...'
    heroku_cmd "run rake db:migrate --app #{APP}"
  end

  task :off do
    puts 'Putting the app into maintenance mode ...'
    heroku_cmd "maintenance:on --app #{APP}"
  end

  task :on do
    puts 'Taking the app out of maintenance mode ...'
    heroku_cmd "maintenance:off --app #{APP}"
  end

  task :push_previous do
    prefix = "#{APP}_release-"
    releases = `git tag`.split("\n").select { |t| t[0..prefix.length-1] == prefix }.sort
    current_release = releases.last
    previous_release = releases[-2] if releases.length >= 2
    if previous_release
      puts "Rolling back to '#{previous_release}' ..."

      puts "Checking out '#{previous_release}' in a new branch on local git repo ..."
      sh "git checkout #{previous_release}"
      sh "git checkout -b #{previous_release}"

      puts "Removing tagged version '#{previous_release}' (now transformed in branch) ..."
      sh "git tag -d #{previous_release}"
      sh "git push #{REMOTE}:#{APP}.git :refs/tags/#{previous_release}"

      puts "Pushing '#{previous_release}' to Heroku master ..."
      sh "git push #{REMOTE}:#{APP}.git +#{previous_release}:master --force"

      puts "Deleting rollbacked release '#{current_release}' ..."
      sh "git tag -d #{current_release}"
      sh "git push #{REMOTE}:#{APP}.git :refs/tags/#{current_release}"

      puts "Retagging release '#{previous_release}' in case to repeat this process (other rollbacks)..."
      sh "git tag -a #{previous_release} -m 'Tagged release'"
      sh "git push --tags #{REMOTE}:#{APP}.git"

      puts "Turning local repo checked out on master ..."
      sh "git checkout master"
      puts 'All done!'
    else
      puts "No release tags found - can't roll back!"
      puts releases
    end
  end
end
