source 'http://rubygems.org'

ruby '2.3.1'

gem 'rails', '~> 4.1.15'

gem 'activeadmin', '~> 1.0.0.pre4'
gem 'attachinary'
gem 'chartkick'
gem 'cloudinary'
gem 'configuration'
gem 'devise', '~> 3.5.4'
gem 'devise-i18n'
gem 'devise-async'
gem 'dotenv-rails'
gem 'font_assets', github: "ericallam/font_assets", branch: 'master'
gem 'foreigner'
gem 'material_icons'
gem 'friendly_id', '~> 5.1.0'
gem 'foreman'
gem 'pundit'
gem 'rails-i18n'
gem "recaptcha", require: "recaptcha/rails"

gem 'central-support', github: 'Codeminer42/cm42-central-support', branch: 'master', require: 'central/support'

gem 'pg'
gem 'pg_search'
gem 'puma'
gem 'sidekiq'
gem 'sidekiq_mailer'
gem 'sinatra', require: nil

gem 'sass-rails'
gem 'uglifier', '>= 2.5.3'
gem 'compass-rails'
gem 'coffee-rails'
gem "autoprefixer-rails"

gem 'bootstrap-sass', '~> 3.3.5'
gem 'i18n-js', '>= 3.0.0.rc8'
gem 'jquery-ui-rails'
gem 'dalli'
gem 'webpack-rails'

gem 'jquery-atwho-rails'
source 'https://rails-assets.org' do
  gem 'rails-assets-jquery.gritter'
end

group :production do
  gem 'kgio'
  gem 'newrelic_rpm'
  gem 'rack-cache'
  gem 'rack-timeout'
  gem 'rails_12factor'
end

group :test do
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rspec-activemodel-mocks'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'poltergeist'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'codeclimate-test-reporter', require: nil
  gem 'vcr'
  gem 'webmock'
  gem 'timecop'
end

group :development do
  gem 'letter_opener'
  gem "better_errors"
  gem "binding_of_caller"
  gem "bullet"
end

group :development, :test do
  gem 'pry-rails'
  gem 'quiet_assets'
end
