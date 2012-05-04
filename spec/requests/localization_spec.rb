require 'spec_helper'

describe "localization" do
  include IntegrationHelpers

  self.use_transactional_fixtures = false

  before(:each) do
    DatabaseCleaner.clean
    sign_in user
  end

  let(:user)  {
    FactoryGirl.create :user, :email => 'user@example.com',
                              :password => 'password'
  }

  describe "user profile" do

    before {user}

    it "lets user change their locale" do
      visit edit_user_registration_path

      select "en", :from => "Locale"
      fill_in "Current password", :with => "password"
      click_on "Update"

      user.locale.should == "en"
    end

  end
end
