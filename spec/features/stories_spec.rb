require 'feature_helper'

describe "Stories" do

  before(:each) do
    sign_in user
  end

  let(:user)     { create :user, :with_team, email: 'user@example.com', password: 'password' }
  let!(:project) { create(:project, name: 'Test Project', users: [user], teams: [user.teams.first] ) }

  describe "full story life cycle" do

    before do
      project
    end

    it "steps through the full story life cycle", js: true do
      visit project_path(project)
      wait_spinner

      click_on 'Add story'

      within('#chilly_bin') do
        fill_in 'title', with: 'New story'
        click_on 'Save'
      end

      # Estimate the story
      within('#chilly_bin .story') do
        find('#estimate-1').trigger 'click'
        click_on 'start'
      end

      sleep 0.5
      within('#in_progress .story') do
        click_on 'finish'
        sleep 0.5
        click_on 'deliver'
        sleep 0.5
        click_on 'accept'
      end

      expect(find('#in_progress .story.accepted .story-title')).to have_content('New story')

    end

  end

  describe "delete a story" do

    let(:story) {
      create(:story, title: 'Delete Me', project: project,
                     requested_by: user)
    }

    before do
      story
    end

    it "deletes the story", js: true do
      visit project_path(project)
      wait_spinner

      within(story_selector(story)) do
        find('.story-title').trigger 'click'
        click_on 'Delete'
      end

      expect(page).not_to have_css(story_selector(story))
    end

  end

  describe "search a story" do
    let(:story) {
      create(:story, title: 'Search for me', project: project,
                     requested_by: user)
    }

    before do
      story
    end

    it 'finds the story', js: true do
      visit project_path(project)
      wait_spinner

      # should not have any search results by default
      expect(page).not_to have_css('.searchResult')

      # fill in the search form
      within('#form_search') do
        fill_in 'q', with: 'Search'
      end
      page.execute_script("$('#form_search').submit()")

      # should return at least one story in the result column
      expect(page).to have_css('.searchResult')

      within(story_selector(story)) do
        find('.story-title').trigger 'click'
        click_on 'Delete'
      end

      # when the story is delete in the results column it should also disappear from other columns
      expect(page).not_to have_css(story_search_result_selector(story))
      expect(page).not_to have_css(story_selector(story))
    end
  end

  describe "show and hide columns" do

    before do
      project
      Capybara.ignore_hidden_elements = true
    end

    it "hides and shows the columns", js: true do

      visit project_path(project)
      wait_spinner

      columns = {
        "done"        => "Done",
        "in_progress" => "In Progress",
        "backlog"     => "Backlog",
        "chilly_bin"  => "Chilly Bin"
      }

      find('.menu-toggle').trigger 'click'

      columns.each do |column, button_text|
        selector = "table.stories td.#{column}_column"
        expect(page).to have_css(selector)

        # Hide the column
        within('#column-toggles') do
          click_on button_text
        end
        expect(page).not_to have_css(selector)

        # Show the column
        within('#column-toggles') do
          click_on button_text
        end
        expect(page).to have_css(selector)

        # close the sidebar
        find('.click-overlay').trigger 'click'

        # Hide the column with the 'close' button in the column header
        within("#{selector} .column_header") do
          click_link 'Close'
        end
        expect(page).not_to have_css(selector)

        # open sidebar again
        find('.menu-toggle').trigger 'click'
      end
    end

    it 'starts with hidden search results column', js: true do
      visit project_path(project)
      wait_spinner

      selector = "table.stories td.search_results_column"
      expect(page).not_to have_css(selector)

      find('.menu-toggle').trigger 'click'

      # Show the column
      within('#column-toggles') do
        click_on "Search Results"
      end
      expect(page).to have_css(selector)

      # close the sidebar
      find('.click-overlay').trigger 'click'

      # Hide the column with the 'close' button in the column header
      within("#{selector} .column_header") do
        click_link 'Close'
      end
      expect(page).not_to have_css(selector)
    end
  end

  describe 'filter by label' do
    let!(:story) { create(:story, title: 'Task 1', project: project,
      requested_by: user, labels: 'epic1') }
    let!(:story2) { create(:story, title: 'Task 2', project: project,
      requested_by: user, labels: 'epic1') }
    let!(:story3) { create(:story, title: 'Task 3', project: project,
      requested_by: user, labels: 'epic2') }

    it 'show epic by label', js: true, driver: :poltergeist do
      visit project_path(project)
      wait_spinner

      expect(page).not_to have_css('.epic_column')
      expect(page).to have_content 'Task 1'
      expect(page).to have_content 'Task 2'
      expect(page).to have_content 'Task 3'

      first(:link, 'epic1').click

      within '.epic_column' do
        expect(page).to have_content 'Task 1'
        expect(page).to have_content 'Task 2'
        expect(page).to_not have_content 'Task 3'
      end

      first(:link, 'epic2').click

      within '.epic_column' do
        expect(page).to_not have_content 'Task 1'
        expect(page).to_not have_content 'Task 2'
        expect(page).to have_content 'Task 3'
      end
    end
  end

  def story_selector(story)
    "#story-#{story.id}"
  end

  def story_search_result_selector(story)
    "#story-search-result-#{story.id}"
  end

end
