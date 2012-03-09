require 'spec_helper'

describe "Confirmations" do

  self.use_transactional_fixtures = false

  before(:each) do
    DatabaseCleaner.clean
  end

  pending "shows confirmation token"
  pending "gracefully handles invalid token"
  pending "sends new confirmation token"

end
