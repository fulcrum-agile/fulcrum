require 'rails_helper'

describe StoriesController do

  describe "when logged out" do
    %w[index done backlog in_progress create].each do |action|
      specify do
        get action, project_id: 99
        expect(response).to redirect_to(new_user_session_url)
      end
    end

    %w[show update destroy].each do |action|
      specify do
        get action, project_id: 99, id: 42
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  context "when logged in" do

    let!(:membership)     { create(:membership) }
    let(:user)            { User.first }
    let(:project)         { Project.first }

    before do
      sign_in user
    end

    describe "#index" do
      specify do
        xhr :get, :index, project_id: project.id
        expect(response).to be_success
        expect(response.body).to eq(project.stories.to_json)
      end
    end

    context "update without losing documents" do
      let(:attachments) { [
        {"id"=>30, "public_id"=>"Screen_Shot_2016-08-19_at_09.30.57_blnr1a", "version"=>"1471624237", "format"=>"png", "resource_type"=>"image", "path"=>"v1471624237/Screen_Shot_2016-08-19_at_09.30.57_blnr1a.png"}, 
        {"id"=>31, "public_id"=>"Screen_Shot_2016-08-19_at_09.30.57_blnr1a", "version"=>"1471624237", "format"=>"png", "resource_type"=>"image", "path"=>"v1471624237/Screen_Shot_2016-08-19_at_09.30.57_blnr1a.png"}
      ]}

      let(:story) { create(:story, project: project, requested_by: user )}

      let(:story_params) do
        { title: "Foo", documents: [ {"file"=> attachments.first}, {"file"=> attachments.last} ]}
      end

      before do
        attachments.each do |a|
          a.delete('path')
          Story.connection.execute("insert into attachinary_files (#{a.keys.join(", ")}, scope, attachinariable_id, attachinariable_type) values ('#{a.values.join("', '")}', 'documents', #{story.id}, 'Story')")
        end
      end

      describe "#update" do
        it "should have 2 documents" do
          story.reload
          expect(story.documents.count).to eq(2)
        end

        it "should keep the same 2 documents (the put will delete and reinsert the documents)" do
          VCR.use_cassette("cloudinary_upload") do
            expect {
              xhr :put, :update, project_id: project.id, id: story.id, story: story_params
            }.to change {story.reload ; story.documents.count}.by(0)
            expect(response).to be_success
          end
        end
      end
    end

    context "member actions" do

      let(:story) { create(:story, project: project, requested_by: user) }
      let(:story_params)  { {title: 'Foo', foo: 'Bar'} }

      describe "#show" do
        specify do
          xhr :get, :show, project_id: project.id, id: story.id
          expect(response).to be_success
          expect(response.body).to eq(story.to_json)
        end
      end

      describe "#update" do
        context "when update succeeds" do
          specify do
            xhr :get, :update, project_id: project.id, id: story.id, story: story_params
            expect(response).to be_success
            expect(response.body).to eq(assigns[:story].to_json)
          end
        end

        context "when update fails" do
          specify do
            xhr :get, :update, project_id: project.id, id: story.id, story: { title: ''}
            expect(response.status).to eq(422)
            expect(response.body).to eq(assigns[:story].to_json)
          end
        end
      end

      describe "#destroy" do
        specify do
          xhr :delete, :destroy, project_id: project.id, id: story.id
          expect(response).to be_success
        end
      end

      %w[done backlog in_progress].each do |action|
        describe action do
          specify do
            xhr :get, action, project_id: project.id, id: story.id
            expect(response).to be_success
            expect(response.body).to eq(assigns[:stories].to_json)
          end
        end
      end

      describe "#create" do
        context "when save succeeds" do
          specify do
            xhr :post, :create, project_id: project.id, story: story_params
            expect(response).to be_success
            expect(response.body).to eq(assigns[:story].to_json)
          end
        end

        context "when save fails" do
          specify do
            xhr :post, :create, project_id: project.id, story: { title: ''}
            expect(response.status).to eq(422)
            expect(response.body).to eq(assigns[:story].to_json)
          end
        end
      end
    end
  end
end
