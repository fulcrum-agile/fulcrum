require 'spec_helper'

describe "Keycuts" do

  include IntegrationHelpers
  
  self.use_transactional_fixtures = false
  
  before(:each) do
    DatabaseCleaner.clean
    sign_in user
  end
  
  let(:user) { FactoryGirl.create :user, :email => 'user@example.com', :password => 'password' }
  let(:project) { FactoryGirl.create :project,  :name => 'Test Project', :users => [user] }
  
  describe "?" do
    it 'shows help', :js => true do
      send_keys '?'
      page.should have_css("#keycut-help")
      page.should have_css("#keycut-help a.close")
    end

    it 'can close help', :js => true do
      send_keys '?'
      within '#keycut-help' do
        click_on 'close'
      end
      page.should_not have_css("#keycut-help")
    end
    
    it 'can close help with ?', :js => true do
      send_keys '?'
      send_keys '?'
      page.should_not have_css("#keycut-help")
    end
  end
  
  describe 'in project scope' do
    before { visit project_path(project) }
    
    it 'adds story (a)', :js => true do
      send_keys 'a'
      page.should have_css('.story.feature.unscheduled.unestimated.editing')
    end
    
    it 'saves currently open story (<ctl> + s)', :js => true do
      click_on 'Add story'
      within('#chilly_bin') do
        fill_in 'title', :with => 'New story'
      end
      send_keys :pause # this is equivalent to keycode 19, or ctl+s (at least on my machine)
      page.should_not have_css('.story.editing')
    end
    
    it 'toggles columns (<shift> b|c|d|p)', :js => true do
      send_keys "B"
      page.should have_css('.hide_backlog.pressed')
      send_keys "B"
      page.should_not have_css('.hide_backlog.pressed')
      
      send_keys "C"
      page.should have_css('.hide_chilly_bin.pressed')
      send_keys "C"
      page.should_not have_css('.hide_chilly_bin.pressed')
      
      send_keys "D"
      page.should have_css('.hide_done.pressed')
      send_keys "D"
      page.should_not have_css('.hide_done.pressed')
      
      send_keys "P"
      page.should have_css('.hide_in_progress.pressed')
      send_keys "P"
      page.should_not have_css('.hide_in_progress.pressed')
    end
  end
end