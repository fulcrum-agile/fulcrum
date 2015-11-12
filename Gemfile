source 'http://rubygems.org'

ruby '2.2.3'

gem 'rails', '~> 4.1.11'

gem 'attachinary'
gem 'cancancan', '~> 1.10'
gem 'cloudinary'
gem 'configuration'
gem 'devise', '~> 3.2.4'
gem 'devise-async'
gem 'dotenv-rails'
gem 'font_assets', github: "ericallam/font_assets", branch: 'master'
gem 'friendly_id', '~> 5.1.0'
gem 'foreman'
gem 'rails-i18n'
gem 'rails-observers', '~> 0.1.2'
gem 'transitions', '0.1.9', require: ['transitions', 'active_record/transitions']

gem 'pg'
gem 'pg_search'
gem 'puma'
gem 'sidekiq'
gem 'sidekiq_mailer'
gem 'sinatra', :require => nil

gem 'sass-rails'
gem 'uglifier', '>= 2.5.3'
gem 'compass-rails'
gem 'coffee-rails'

gem 'bootstrap-sass', '~> 3.3.5'
gem 'ejs'
gem 'i18n-js', '>= 3.0.0.rc8'
gem 'jquery-rails'
gem 'jquery-ui-rails'

source 'https://rails-assets.org' do
  gem 'rails-assets-backbone'
  gem 'rails-assets-date.format'
  gem 'rails-assets-jquery.gritter'
  gem 'rails-assets-jquery.scrollTo'
  gem 'rails-assets-underscore'
end

group :production do
  gem 'dalli'
  gem 'kgio'
  gem 'newrelic_rpm'
  gem 'rack-cache'
  gem 'rack-timeout'
  gem 'rails_12factor'
end

group :development do
  gem 'letter_opener'
end

group :development, :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'jasmine-rails'
  gem 'poltergeist'
  gem 'pry-rails'
  gem 'quiet_assets'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rspec-activemodel-mocks'
  gem 'sinon-rails'
end
