require 'spec_helper'

describe "Logins" do

  let(:user)  {
    FactoryGirl.create :user, :email => 'user@example.com',
                              :password => 'password'
  }

  describe "successful login" do

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

  describe "successful logout", :js => true do
    before do
      sign_in user
    end

    it "logs out the user" do
      visit root_path
      click_on 'Log out'

      page.should have_selector('h1', :text => 'Sign in')
    end
  end

end
