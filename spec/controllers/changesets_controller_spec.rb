require 'rails_helper'

describe ChangesetsController do

  context "when logged out" do

    it "redirects to the login page" do
      xhr :get, :index, project_id: 42
      expect(response.status).to eq(401)
    end

  end

  context "when logged in" do

    let(:user)        { create :user, :with_team }
    let(:project)     { create(:project, users: [user], teams: [user.teams.first]) }

    let(:story) { create :story, project: project, requested_by: user }
    let(:story2) { create :story, project: project, requested_by: user }

    before do
      @changeset1 = story.changesets.create!
      @changeset2 = story.changesets.create!

      sign_in user
    end

    describe "#index" do

      specify do
        xhr :get, :index, project_id: project.id
        expect(response).to be_success
        expect(assigns[:project]).to eq(project)
        expect(assigns[:changesets].count).to eq(2)
        expect(response.content_type).to eq("application/json")
        cs1, cs2 = JSON.parse(response.body)
        expect(cs1["changeset"]["id"]).to eq(@changeset1.id)
        expect(cs1["changeset"]["story_id"]).to eq(@changeset1.story_id)
        expect(cs1["changeset"]["project_id"]).to eq(@changeset1.project_id)
        expect(cs2["changeset"]["id"]).to eq(@changeset2.id)
        expect(cs2["changeset"]["story_id"]).to eq(@changeset2.story_id)
        expect(cs2["changeset"]["project_id"]).to eq(@changeset2.project_id)
      end

      it "scopes on :to parameter" do
        xhr :get, :index, project_id: project.id, to: @changeset2.id
        expect(assigns[:changesets]).to eq([@changeset1, @changeset2])
      end

      it "scopes on :from parameter" do
        xhr :get, :index, project_id: project.id, from: @changeset1.id
        expect(assigns[:changesets]).to eq([@changeset2])
      end

    end

  end

end
