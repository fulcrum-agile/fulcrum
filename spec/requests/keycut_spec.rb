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
      find('html').native.send_keys '?'
      page.should have_css("#keycut-help")
      page.should have_css("#keycut-help a.close")
    end

    it 'can close help', :js => true do
      find('html').native.send_keys '?'
      within '#keycut-help' do
        click_on 'close'
      end
      page.should_not have_css("#keycut-help")
    end
    
    it 'can close help with ?', :js => true do
      find('html').native.send_keys '?'
      find('html').native.send_keys '?'
      page.should_not have_css("#keycut-help")
    end
  end
  
  describe 'in project scope' do
    before { project }
    
    it 'adds story (a)', :js => true do
      visit project_path(project)
      find('html').native.send_keys 'a'
      page.should have_css('.story.feature.unscheduled.unestimated.editing')
    end
    
    it 'saves currently open story (<cmd> + s)'
    
    it 'toggles backlog (<shift> + b)'

    it 'toggles done (<shift> + d)'

    it 'toggles chilly bin (<shift> + i)'

    it 'toggles current (<shift> + c)'
    
    it 'saves comment being edited (<shift> + enter)'
  end
end