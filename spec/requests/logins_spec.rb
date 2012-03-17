require 'spec_helper'

describe "Logins" do

  self.use_transactional_fixtures = false

  before(:each) do
    DatabaseCleaner.clean
  end

  describe "successful login" do

    let(:user)  {
      FactoryGirl.create :user, :email => 'user@example.com',
                                :password => 'password'
    }

    before { user }

    it "logs in the user", :js => true do
      visit root_path
      page.should have_selector('h1', :text => 'Sign in')

      fill_in "Email",    :with => "user@example.com"
      fill_in "Password", :with => "password"
      click_button 'Sign in'

      page.should have_selector('h1', :text => 'Listing Projects')
      page.should have_selector('#primary-nav', :text => 'user@example.com')
    end

  end
end
