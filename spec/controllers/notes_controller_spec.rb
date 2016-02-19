require 'rails_helper'

describe NotesController do

  let(:user)            { FactoryGirl.create :user }
  let(:project)         { mock_model(Project, :id => 42) }
  let(:story)           { mock_model(Story, :id => 99) }
  let(:projects)        { double("projects") }
  let(:stories)         { double("stories") }
  let(:notes)           { double("notes", :to_json => '{foo:bar}') }
  let(:note)            { mock_model(Note, :id => 66, :to_json => '{foo:bar}') }
  let(:request_params)  { {:project_id => project.id, :story_id => story.id } }

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
      allow(user).to receive_messages(:projects => projects)
      allow(projects).to receive(:find).with(project.id.to_s).and_return(project)
      allow(project).to receive_messages(:stories => stories)
      allow(stories).to receive(:find).with(story.id.to_s).and_return(story)
      allow(story).to receive_messages(:notes => notes)
      allow(notes).to receive(:find).with(note.id.to_s).and_return(note)
      allow(subject).to receive_messages(:current_user => user)

      sign_in user
    end

    describe "collection actions" do

      describe "#index" do

        specify do
          xhr :get, :index, request_params
          expect(response).to be_success
          expect(assigns[:project]).to eq(project)
          expect(assigns[:story]).to eq(story)
          expect(assigns[:notes]).to eq(notes)
          expect(response.content_type).to eq("application/json")
          expect(response.body).to eq(notes.to_json)
        end

      end

      describe "#create" do

        before do
          request_params[:note] = {'note' => 'bar'}
          expect(notes).to receive(:build).with(request_params[:note]).and_return(note)
          expect(note).to receive(:user=).with(user)
          allow(note).to receive_messages(:save => true)
        end

        specify do
          xhr :post, :create, request_params
          expect(response).to be_success
          expect(assigns[:project]).to eq(project)
          expect(assigns[:story]).to eq(story)
          expect(assigns[:note]).to eq(note)
          expect(response.content_type).to eq("application/json")
          expect(response.body).to eq(note.to_json)
        end

        context "when save fails" do

          before do
            allow(note).to receive_messages(:save => false)
          end

          specify do
            xhr :post, :create, request_params
            expect(response.status).to eq(422)
          end

        end

      end

    end

    describe "member actions" do

      let(:request_params) {
        {:id => note.id, :project_id => project.id, :story_id => story.id}
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

        before do
          expect(note).to receive(:destroy)
        end

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
