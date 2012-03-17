require 'spec_helper'

describe "Stories" do

  include IntegrationHelpers

  self.use_transactional_fixtures = false

  before(:each) do
    DatabaseCleaner.clean
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

  describe "full story life cycle" do

    before do
      project
    end

    it "steps through the full story life cycle", :js => true do
      visit project_path(project)

      click_on 'Add story'

      within('#chilly_bin') do
        fill_in 'title', :with => 'New story'
        click_on 'Save'
      end

      # Estimate the story
      within('#chilly_bin .story') do
        click_on '1'
        click_on 'start'
      end

      within('#in_progress .story') do
        click_on 'finish'
        click_on 'deliver'
        click_on 'accept'
      end

      find('#in_progress .story.accepted .story-title').should have_content('New story')

    end

  end

end
