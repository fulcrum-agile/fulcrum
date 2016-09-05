require 'rails_helper'

describe NotesController do

  let(:user)           { create :user, :with_team, email: 'user@example.com', password: 'password' }
  let(:project)        { create(:project, name: 'Test Project', users: [user], teams: [user.teams.first] ) }
  let(:story)          { create(:story, project: project, requested_by: user) }
  let(:request_params) { { project_id: project.id, story_id: story.id } }

  context "when not logged in" do

    describe "collection actions" do

      specify "#index" do
        xhr :get, :index, request_params
        expect(response.status).to eq(401)
      end

      specify "#create" do
        xhr :post, :create, request_params
        expect(response.status).to eq(401)
      end

    end

    describe "member actions" do

      before do
        note = create(:note, story: story)
        request_params[:id] = note.id
      end

      specify "#show" do
        xhr :get, :show, request_params
        expect(response.status).to eq(401)
      end

      specify "#destroy" do
        xhr :delete, :destroy, request_params
        expect(response.status).to eq(401)
      end

    end

  end

  context "when logged in" do
    before do
      sign_in user
    end

    describe "collection actions" do
      describe "#index" do
        specify do
          xhr :get, :index, request_params
          expect(response).to be_success
          expect(assigns[:project]).to eq(project)
          expect(assigns[:story]).to eq(story)
          expect(assigns[:notes]).to eq(story.notes)
          expect(response.content_type).to eq("application/json")
          expect(response.body).to eq(story.notes.to_json)
        end
      end

      describe "#create" do
        specify do
          xhr :post, :create, request_params.merge(note: {note: 'bar'})
          expect(response).to be_success
          expect(assigns[:project]).to eq(project)
          expect(assigns[:story]).to eq(story)
          expect(assigns[:note]).to_not be_nil
          expect(response.content_type).to eq("application/json")
          expect(response.body).to eq(Note.last.to_json)
        end

        context "when save fails" do
          specify do
            xhr :post, :create, request_params.merge(note: {note: ''})
            expect(response.status).to eq(422)
          end
        end
      end
    end

    describe "member actions" do
      let(:note) { create(:note, story: story) }
      let(:request_params) {
        {id: note.id, project_id: project.id, story_id: story.id}
      }

      describe "#show" do
        specify do
          xhr :get, :show, request_params
          expect(response).to be_success
          expect(assigns[:project]).to eq(project)
          expect(assigns[:story]).to eq(story)
          expect(assigns[:note]).to eq(note)
          expect(response.content_type).to eq("application/json")
          expect(response.body).to eq(note.to_json)
        end
      end

      describe "#destroy" do
        specify do
          xhr :delete, :destroy, request_params
          expect(response).to be_success
          expect(assigns[:project]).to eq(project)
          expect(assigns[:story]).to eq(story)
          expect(assigns[:note]).to eq(note)
          expect(response.body).to be_blank
        end
      end
    end
  end
end
