namespace :travis do

  desc "Runs rspec specs and jasmine specs on travis"
  task :run_specs do
    ["rspec spec", "rake --trace  jasmine:ci"].each do |cmd|
      puts "Starting to run #{cmd}..."
      system("export DISPLAY=:99.0 && bundle exec #{cmd}")
      raise "#{cmd} failed!" unless $?.exitstatus == 0
    end
  end

end

task :travis => 'travis:run_specs'