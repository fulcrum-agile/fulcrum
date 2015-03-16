source 'http://rubygems.org'

ruby '2.2.1'

gem 'rails', '~> 4.1.9'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 2.5.3'
gem 'jquery-rails'
gem 'ejs'
gem 'compass-rails'
gem 'devise', '~> 3.2.4'
gem 'transitions', '0.1.9', require: ['transitions', 'active_record/transitions']
gem 'rails-i18n'
gem 'configuration'
gem 'rails-observers', '~> 0.1.2'
gem 'jquery-ui-rails'

gem 'pg', group: :postgres
gem 'mysql2', group: :mysql
gem 'sqlite3', group: :sqlite

group :production do
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
