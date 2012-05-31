source 'http://rubygems.org'

gem 'rails', '~> 3.2.2'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.2.0"
  gem 'uglifier'
  gem 'compass-rails'
  gem 'ejs'
end

gem 'jquery-rails'

gem 'devise'
gem 'cancan'
gem 'transitions', '0.0.9', :require => ["transitions", "active_record/transitions"]

gem 'fastercsv', '1.5.3', :platforms => :ruby_18
# (using standard csv lib if ruby version is 1.9)

group :production do
  platforms :ruby do
    gem 'pg'
  end
  platforms :jruby do
    gem 'activerecord-jdbcpostgresql-adapter'
  end
end

group :development, :test do

  platforms :ruby do
    gem 'sqlite3'
  end
  platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter'
    gem 'activerecord-jdbcpostgresql-adapter'
  end

  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'jasmine', '1.1.0'
  gem 'rspec-rails'
end
