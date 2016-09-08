ENV["RAILS_ENV"] = 'capybara'

RSpec.configure do |config|
  config.before(:suite) do
    %x[bundle exec rake assets:precompile]
  end
end
