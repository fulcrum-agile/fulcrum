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

    let(:projects)    { mock("projects") }
    let(:changesets)  { mock("changesets", :to_json => '{foo:bar}') }

    before do
      sign_in user
      subject.stub(:current_user => user)
      user.stub(:projects => projects)
      projects.stub(:find).with(project.id.to_s).and_return(project)
      project.stub_chain(:changesets, :scoped).and_return(changesets)
    end

    describe "#index" do

      it "is successful" do
        xhr :get, :index, :project_id => project.id
        response.should be_success
      end

      it "is assigns @project" do
        xhr :get, :index, :project_id => project.id
        assigns[:project].should == project
      end

      it "is assigns @changesets" do
        xhr :get, :index, :project_id => project.id
        assigns[:changesets].should == changesets
      end

      it "has content type text/json" do
        xhr :get, :index, :project_id => project.id
        response.content_type.should == :json
      end

      it "returns the changesets as JSON" do
        xhr :get, :index, :project_id => project.id
        response.body.should == '{foo:bar}'
      end

      it "scopes on :to parameter" do
        changesets.should_receive(:where).with('id <= ?', '99')
        xhr :get, :index, :project_id => project.id, :to => 99
      end

      it "scopes on :from parameter" do
        changesets.should_receive(:where).with('id > ?', '99')
        xhr :get, :index, :project_id => project.id, :from => 99
      end

    end

  end

end
