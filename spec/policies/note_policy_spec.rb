require 'rails_helper'

describe NotePolicy do
  let(:other_member) { create :user, name: 'Anyone' }
  let(:note) { create :note, story: story }
  let(:story) { create :story, project: project, requested_by: other_member }
  let(:project) { create :project }
  let(:pundit_context) { PunditContext.new(current_user, current_project: project, current_story: story) }
  let(:policy_scope) { NotePolicy::Scope.new(pundit_context, Note).resolve.all }

  subject { NotePolicy.new(pundit_context, note) }

  before { project.users << other_member }

  context "proper user of a project" do
    before do
      project.users << current_user
    end

    context "for an admin" do
      let(:current_user) { create :user, name: 'admin', is_admin: true }

      %i[index show create new update edit destroy].each do |action|
        it { should permit(action) }
      end

      it 'lists all notes' do
        expect(policy_scope).to eq([note])
      end
    end

    context "for a user" do
      let(:current_user) { create :user, is_admin: false }

      it { should permit(:show) }

      %i[index show create new update edit destroy].each do |action|
        it { should permit(action) }
      end

      it 'lists all notes' do
        expect(policy_scope).to eq([note])
      end
    end
  end

  context "user not a member of project" do
    context "for an admin" do
      let(:current_user) { create :user, name: 'admin', is_admin: true }

      %i[index show create new update edit destroy].each do |action|
        it { should permit(action) }
      end

      it 'lists all notes' do
        expect(policy_scope).to eq([note])
      end
    end

    context "for a user" do
      let(:current_user) { create :user, is_admin: false }

      %i[index create new update edit destroy].each do |action|
        it { should_not permit(action) }
      end

      it 'lists no notes' do
        expect(policy_scope).to eq([])
      end
    end
  end
end


