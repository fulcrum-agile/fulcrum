require 'rails_helper'

describe "Notes" do

  before(:each) do
    # FIXME - Having to set this really high for the 'adds a note to a story
    # spec'.  Need to work on making it more responsive.
    Capybara.default_max_wait_time = 10
    sign_in user
  end

  let(:user)  {
    FactoryGirl.create :user, :email => 'user@example.com',
                              :password => 'password'
  }

  let!(:project) do
    FactoryGirl.create :project,  :name => 'Test Project',
                                  :users => [user]
  end

  let!(:story) do
    FactoryGirl.create :story,  :title => 'Test Story',
                                :state => 'started',
                                :project => project,
                                :requested_by => user
  end

  describe "full story life cycle" do

    it "adds a note to a story", js: true, driver: :poltergeist do
      visit project_path(project)

      within('#in_progress .story') do
        find('.story-title').trigger('click')
        fill_in 'note', :with => 'Adding a new note'
        click_on 'Add note'
      end

      sleep 0.5
      expect(find('#in_progress .story .notelist .note')).to have_content('Adding a new note')

    end

  	it "deletes a note from a story", js: true, driver: :poltergeist do
      FactoryGirl.create :note, :user => user,
                                :story => story,
                                :note => 'Delete me please'

      visit project_path(project)

      within('#in_progress .story') do
        find('.story-title').trigger('click')
        within('.notelist') do
          click_on 'Delete'
        end
      end

      sleep 0.5
      expect(find('#in_progress .story .notelist')).not_to have_content('Delete me please')
    end

  end

end
