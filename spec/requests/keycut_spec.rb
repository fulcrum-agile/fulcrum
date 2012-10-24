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

    it 'can hide help', :js => true do
      find('html').native.send_keys '?'
      within '#keycut-help' do
        click_on 'close'
      end
      page.should_not have_css("#keycut-help")
    end
  end
  
  describe "a" do
    before { project }
    
    it 'adds story', :js => true do
      visit project_path(project)
      find('html').native.send_keys 'a'
      page.should have_css('.story.feature.unscheduled.unestimated.editing')
    end
  end

  it 'saves currently open story with <Cmd> + s'

  it 'saves comment being edited with <Shift> + enter'

  it 'toggles backlog with <Shift> + b'

  it 'toggles charts (graphs) with <Shift> + g'

  it 'toggles done with <Shift> + d'

  it 'toggles history with <Shift> + h'

  it 'toggles icebox with <Shift> + i'

  it 'toggles my work with <Shift> + w'

  it 'toggles labels & searches with <Shift> + l'

  it 'toggles current with <Shift> + c'

  xit 'adds epic with e'

  xit 'toggles epics panel with <Shift> + e'
end