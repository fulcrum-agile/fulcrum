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

  # I am pretty sure there is a better way to do this 
  let(:current_user) {
    User.where(:email => "user@example.com").first
  }

  describe "user profile" do

    it "lets user change their locale" do
      visit edit_user_registration_path

      select "en", :from => "Locale"
      fill_in "Current password", :with => "password"
      click_on "Update"

      current_user.locale.should == "en"
    end

  end
end
