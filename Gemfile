source 'http://rubygems.org'

ruby '2.2.1'

gem 'rails', '~> 4.1.11'
gem 'devise', '~> 3.2.4'
gem 'transitions', '0.1.9', require: ['transitions', 'active_record/transitions']
gem 'rails-i18n'
gem 'configuration'
gem 'rails-observers', '~> 0.1.2'

gem 'pg'
gem 'puma'

gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 2.5.3'
gem 'compass-rails'

gem 'jquery-rails'
gem 'ejs'
gem 'jquery-ui-rails'
gem "i18n-js", ">= 3.0.0.rc8" 

source 'https://rails-assets.org' do
  gem 'rails-assets-backbone'
  gem 'rails-assets-underscore'
  gem 'rails-assets-bootstrap'
  gem 'rails-assets-jquery.gritter'
  gem 'rails-assets-jquery.scrollTo'
  gem 'rails-assets-date.format'
end

group :production do
  gem 'dalli'
  gem 'rack-timeout'
  gem 'rack-cache'
  gem 'kgio'
  gem 'newrelic_rpm'
  gem 'rails_12factor'
end

group :development do
  gem 'letter_opener'
end

group :development, :test do
  gem 'pry'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rspec-activemodel-mocks'
  gem 'factory_girl_rails'
  gem 'jasmine-rails'
  gem 'sinon-rails'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'quiet_assets'
end
