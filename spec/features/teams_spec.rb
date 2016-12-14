require 'feature_helper'

describe "Teams" do
  let!(:user)  {
    create :user, :with_team,
      email: 'user@example.com',
      password: 'password',
      name: 'Test User',
      locale: 'en',
      time_zone: 'Brasilia'
  }

  describe "create team" do
    before { sign_in user }

    it "should create a new team and set the user as admin" do
      visit teams_path
      click_link 'Create new Team'

      fill_in "Team Name",     with: "foobar"
      click_button 'Create new Team'

      expect(user.teams.last.is_admin?(user)).to be_truthy
    end
  end
end
