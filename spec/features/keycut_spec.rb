require 'feature_helper'

describe "Keycuts" do

  self.use_transactional_fixtures = false

  before(:each) do
    ActionController::Base.allow_forgery_protection = false
    DatabaseCleaner.clean
    sign_in user
  end

  let(:user) { create :user, :with_team, email: 'user@example.com', password: 'password' }
  let(:project) { create :project,  name: 'Test Project', users: [user], teams: [user.teams.first] }

  describe "?" do
    it 'shows help', js: true do
      send_keys '?'
      expect(page).to have_css("#keycut-help")
      expect(page).to have_css("#keycut-help a.close")
    end

    it 'can close help', js: true do
      send_keys '?'
      within '#keycut-help' do
        click_on 'close'
      end
      expect(page).not_to have_css("#keycut-help")
    end

    it 'can close help with ?', js: true do
      send_keys '?'
      send_keys '?'
      expect(page).not_to have_css("#keycut-help")
    end
  end

  describe 'in project scope' do
    before do
      visit project_path(project)
      wait_spinner
    end

    it 'adds story (a)', js: true do
      send_keys 'a'
      expect(page).to have_css('.story.feature.unscheduled.unestimated.editing')
    end

    it 'saves currently open story (<ctl> + s)', js: true do
      click_on 'Add story'
      within('#chilly_bin') do
        fill_in 'title', with: 'New story'
      end
      send_keys :pause # this is equivalent to keycode 19, or ctl+s (at least on my machine)
      expect(page).not_to have_css('.story.editing')
    end

    it 'toggles columns (<shift> b|c|d|p)', js: true do
      find('.menu-toggle').trigger 'click'

      send_keys "B"
      expect(page).to have_css('.hide_backlog.pressed')
      send_keys "B"
      expect(page).not_to have_css('.hide_backlog.pressed')

      send_keys "C"
      expect(page).to have_css('.hide_chilly_bin.pressed')
      send_keys "C"
      expect(page).not_to have_css('.hide_chilly_bin.pressed')

      send_keys "D"
      expect(page).to have_css('.hide_done.pressed')
      send_keys "D"
      expect(page).not_to have_css('.hide_done.pressed')

      send_keys "P"
      expect(page).to have_css('.hide_in_progress.pressed')
      send_keys "P"
      expect(page).not_to have_css('.hide_in_progress.pressed')
    end
  end
end
