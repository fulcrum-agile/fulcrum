source 'http://rubygems.org'

ruby '2.1.2'

gem 'rails', '~> 4.1.4'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 2.5.3'
gem 'coffee-rails', '~> 4.0.1'
gem 'jquery-rails'
gem 'jbuilder', '~> 1.2'
gem 'ejs'
gem "compass-rails", '~> 2.0.0'
gem "devise", "~> 3.2.4"
gem 'transitions', '0.1.9', :require => ["transitions", "active_record/transitions"]
gem 'rails-i18n'
gem 'configuration'
gem 'rails-observers', '~> 0.1.2'
gem 'jquery-ui-rails'
gem 'pg'

group :production do
  # This helps with serving assets and log files on the heroku platform.
  # See https://github.com/heroku/rails_12factor
  # https://devcenter.heroku.com/articles/rails4#logging-and-assets
  gem 'rails_12factor'
end

group :development do
  gem 'letter_opener'
end

group :development, :test do
  gem 'pry'
  gem 'sqlite3'
  gem 'rspec-rails', '~> 2.99.0'
  gem 'rspec-its'
  gem 'rspec-activemodel-mocks'
  gem 'factory_girl_rails'
  gem 'jasmine', '~> 1.3.2'
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'quiet_assets'
end

group :travis do
  gem 'mysql2'
end

if ENV['TRAVIS'] == 'true'
  group :test do
    case ENV['DB']
    when'mysql'
      gem 'mysql2'
    when 'postgresql'
      gem 'pg'
    else
      gem 'sqlite3'
    end
  end
end
