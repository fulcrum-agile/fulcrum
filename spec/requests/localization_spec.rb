require 'spec_helper'

describe "localization" do

  before(:each) do
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
      change_locale_to "en"

      current_user.locale.should == "en"
    end

  end

  def change_locale_to new_locale
    visit edit_user_registration_path

    select new_locale, :from => "Locale"
    fill_in "Current password", :with => "password"
    click_on "Update"
  end

  describe "application" do

    it "sets the locale based on the user locale" do
      change_locale_to "es"

      visit root_path

      page.should have_selector('h1', :text => 'Listado de Proyectos')
    end

  end
end
