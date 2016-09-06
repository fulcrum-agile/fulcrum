require 'rails_helper'

describe "Logins" do

  let(:user)  {
    create :user, :with_team_and_is_admin,
                  email: 'user@example.com',
                  password: 'password',
                  name: 'Test User',
                  locale: 'en',
                  time_zone: 'Brasilia'
  }

  describe "disable registration" do
    before do
      Configuration.for('fulcrum') do
        disable_registration true
      end
    end

    after do
      Configuration.for('fulcrum') do
        disable_registration false
      end
    end

    it "removes the sign up link" do
      visit root_path
      expect(page).to have_selector('h1', text: 'Sign in')

      expect(page).not_to have_selector('a', text: 'Sign up')
    end
  end

  describe "successful login" do

    let(:team) { user.teams.first }

    it "logs in the user", js: true do
      visit root_path
      expect(page).to have_selector('h1', text: 'Sign in')

      fill_in "Email",     with: "user@example.com"
      fill_in "Password",  with: "password"
      fill_in "Team slug", with: team.slug
      click_button 'Sign in'

      expect(page).to have_selector('#title_bar', text: 'New Project')
      find('.menu-toggle').trigger 'click'
      expect(page).to have_selector('.sidebar-nav li:nth-child(6)', text: 'Test User')
    end

    it "switches team through URL and doesn't have to fill in the team slug", js: true do
      visit teams_switch_path(team.slug)
      expect(page).to have_selector('#user_team_slug'), text: team.slug

      fill_in "Email",     with: "user@example.com"
      fill_in "Password",  with: "password"
      click_button 'Sign in'

      expect(page).to have_selector('#title_bar', text: 'New Project')
    end

  end

  describe "new team" do
    let!(:team) { create :team }

    it "first login" do
      expect(team.is_admin?(user)).to be_falsey

      visit teams_switch_path(team.slug)

      fill_in "Email",     with: "user@example.com"
      fill_in "Password",  with: "password"
      click_button 'Sign in'

      expect(team.is_admin?(user)).to be_truthy
    end
  end

  describe "successful logout", js: true do
    before do
      sign_in user
    end

    it "logs out the user" do
      visit root_path
      find('.menu-toggle').trigger 'click'
      click_on 'Log out'

      expect(page).to have_selector('h1', text: 'Sign in')
    end
  end

end
