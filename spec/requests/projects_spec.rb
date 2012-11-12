require 'spec_helper'

describe "Projects" do

  before(:each) do
    sign_in user
  end

  let(:user)  {
    FactoryGirl.create :user, :email => 'user@example.com',
                              :password => 'password'
  }

  describe "list projects" do

    before do
      FactoryGirl.create :project,  :name => 'Test Project',
                                    :users => [user]
    end

    it "shows the project list", :js => true do
      visit projects_path

      page.should have_selector('h1', :text => 'Listing Projects')

      click_on 'Test Project'

      page.should have_selector('h1', :text => 'Test Project')
    end

  end

  describe "create project" do

    it "creates a project", :js => true do
      visit projects_path
      click_on 'New Project'

      fill_in 'Name', :with => 'New Project'
      click_on 'Create Project'

      page.should have_selector('h1', :text => 'New Project')
      current_path.should == project_path(Project.find_by_name('New Project'))
    end

  end

  describe "edit project" do

    let(:project) {
      FactoryGirl.create :project,  :name => 'Test Project',
                                    :users => [user]
    }

    before do
      project
    end

    it "edits a project" do
      visit projects_path
      within('#projects .project_options') do
        click_on 'Edit'
      end

      fill_in 'Name', :with => 'New Project Name'
      click_on 'Update Project'

      page.should have_selector('h1', :text => 'New Project Name')
      current_path.should == project_path(project)
    end

    it "shows form errors" do
      visit projects_path
      within('#projects .project_options') do
        click_on 'Edit'
      end

      fill_in 'Name', :with => ''
      click_on 'Update Project'

      page.should have_content("Name can't be blank")
    end
  end

  describe "delete project" do

    let(:project) {
      FactoryGirl.create :project,  :name => 'Test Project',
                                    :users => [user]
    }

    before do
      project
    end

    it "deletes a project" do
      visit projects_path
      within('#projects .project_options') do
        click_on 'Delete'
      end

      page.should_not have_content('Test Project')
      Project.count.should == 0
    end
  end

end
