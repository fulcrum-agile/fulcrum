source 'http://rubygems.org'

ruby '2.0.0'

gem 'rails', '4.0.2'
gem 'sass-rails', '~> 4.0.1'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.1'
gem 'jquery-rails'
gem 'jbuilder', '~> 1.2'
gem 'ejs'
gem "compass-rails", "~> 1.1.2"
gem "devise", "~> 3.2.0"
gem 'transitions', '0.1.9', :require => ["transitions", "active_record/transitions"]
gem 'rails-i18n'
gem 'configuration'
gem 'rails-observers', '~> 0.1.2'
# gem 'protected_attributes'
gem 'jquery-ui-rails'

group :production do
  gem 'pg'
  # This helps with serving assets and log files on the heroku platform.
  # See https://github.com/heroku/rails_12factor
  # https://devcenter.heroku.com/articles/rails4#logging-and-assets
  gem 'rails_12factor'
end

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'jasmine', '~> 1.3.2'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'database_cleaner'
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
