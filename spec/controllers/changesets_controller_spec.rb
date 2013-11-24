require 'spec_helper'

describe ChangesetsController do

  let(:project) { mock_model(Project, :id => 42) }

  context "when logged out" do

    it "redirects to the login page" do
      xhr :get, :index, :project_id => project.id
      response.status.should == 401
    end

  end

  context "when logged in" do

    let(:user) do
      FactoryGirl.create :user
    end

    let(:projects)    { double("projects") }
    let(:changesets)  { double("changesets", :to_json => '{foo:bar}') }

    before do
      sign_in user
      subject.stub(:current_user => user)
      user.stub(:projects => projects)
      projects.stub(:find).with(project.id.to_s).and_return(project)
      project.stub(:changesets).and_return(changesets)
    end

    describe "#index" do

      specify do
        xhr :get, :index, :project_id => project.id
        response.should be_success
        assigns[:project].should == project
        assigns[:changesets].should == changesets
        response.content_type.should == "application/json"
        response.body.should == '{foo:bar}'
      end

      it "scopes on :to parameter" do
        changesets.should_receive(:until).with('99')
        xhr :get, :index, :project_id => project.id, :to => 99
      end

      it "scopes on :from parameter" do
        changesets.should_receive(:since).with('99')
        xhr :get, :index, :project_id => project.id, :from => 99
      end

    end

  end

end
