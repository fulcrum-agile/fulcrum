require 'rails_helper'

describe TasksController do

  let!(:membership)     { create(:membership) }
  let(:user)            { User.first }
  let(:project)         { Project.first }
  let(:story)           { create(:story, project: project, requested_by: user) }
  let(:request_params)  { { project_id: project.id, story_id: story.id } }

  context 'when not logged in' do
    context '#create' do
      specify do
        xhr :post, :create, request_params
        is_expected.to respond_with 401
      end
    end

    context '#destroy' do
      specify do
        xhr :delete, :destroy, request_params.merge(id: 1)
        is_expected.to respond_with 401
      end
    end
  end

  context 'when logged in' do
    before do
      sign_in user
    end

    describe '#create' do
      specify do
        xhr :post, :create, request_params.merge(task: { name: 'task name' })

        task = assigns[:task]
        expect(response).to be_success
        expect(assigns[:project]).to eq(project)
        expect(assigns[:story]).to eq(story)
        expect(task).to_not be_nil
        expect(response.content_type).to eq('application/json')
        expect(response.body).to eq(task.to_json)
      end

      context 'when save fails' do
        specify do
          xhr :post, :create, request_params.merge(task: { name: '' })
          is_expected.to respond_with 422
        end
      end
    end

    describe '#destroy' do
      specify do
        task = create(:task, story: story)

        xhr :delete, :destroy, request_params.merge(id: task.id)
        expect(response).to be_success
        expect(assigns[:project]).to eq(project)
        expect(assigns[:story]).to eq(story)
        expect(assigns[:task]).to eq(task)
        expect(response.body).to be_blank
      end
    end
  end
end
