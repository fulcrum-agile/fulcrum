require 'capybara/rspec'
require 'capybara/poltergeist'
require 'capybara-screenshot/rspec'

Capybara.register_driver :poltergeist do |app|
  phantomjs_path = Rails.root.join("node_modules/.bin/phantomjs").to_s
  Capybara::Poltergeist::Driver.new(app, phantomjs: phantomjs_path)
end

Capybara.default_max_wait_time = 100

Capybara.javascript_driver = :poltergeist
