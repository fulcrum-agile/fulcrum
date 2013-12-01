namespace :travis do

  desc "Runs rspec specs on travis"
  task :run_specs do
    ["rspec spec"].each do |cmd|
      puts "Starting to run #{cmd}..."
      system("export DISPLAY=:99.0 && bundle exec #{cmd}")
      raise "#{cmd} failed!" unless $?.exitstatus == 0
    end
  end

end

task :travis => 'travis:run_specs'
