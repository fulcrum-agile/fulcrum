require 'capybara/rspec'
require 'capybara/poltergeist'
require 'capybara-screenshot/rspec'
require 'phantomjs'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, phantomjs: Phantomjs.path)
end

Capybara.javascript_driver = :poltergeist
