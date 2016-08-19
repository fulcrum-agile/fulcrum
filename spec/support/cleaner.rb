RSpec.configure do |config|
  config.before(:suite) { DatabaseCleaner.clean_with(:truncation) }

  config.before(:each) do |example|
    DatabaseCleaner.strategy = example.metadata[:js] ? :deletion : :transaction
    DatabaseCleaner.start
  end

  config.after(:each) { DatabaseCleaner.clean }
end
