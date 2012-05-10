require 'spec_helper'

describe "Notes" do

  include IntegrationHelpers

  self.use_transactional_fixtures = false

  before(:each) do
    DatabaseCleaner.clean
    # FIXME - Having to set this really high for the 'adds a note to a story
    # spec'.  Need to work on making it more responsive.
    Capybara.default_wait_time = 10
    sign_in user
  end

  let(:user)  {
    FactoryGirl.create :user, :email => 'user@example.com',
                              :password => 'password'
  }

  let(:project) do
    FactoryGirl.create :project,  :name => 'Test Project',
                                  :users => [user]
  end

  let(:story) do
    FactoryGirl.create :story,  :title => 'Test Story',
                                :state => 'started',
                                :project => project,
                                :requested_by => user
  end

  describe "full story life cycle" do

    before do
      story
    end

    it "adds a note to a story", :js => true do
      visit project_path(project)

      within('#in_progress .story') do
        click_on 'Expand'
        fill_in 'note', :with => 'Adding a new note'
        click_on 'Add note'
      end

      find('#in_progress .story .notelist .note').should have_content('Adding a new note')

    end

  end

end
