require 'rails_helper'

describe NotePolicy do
  let(:other_member) { create :user, name: 'Anyone' }
  let(:note) { create :note, story: story }
  let(:story) { create :story, project: project, requested_by: other_member }
  let(:project) { create :project }
  let(:pundit_context) { PunditContext.new(current_team, current_user, current_project: project, current_story: story) }
  let(:current_team) { current_user.teams.first }
  let(:policy_scope) { NotePolicy::Scope.new(pundit_context, Note).resolve.all }

  subject { NotePolicy.new(pundit_context, note) }

  before do
    project.users << other_member
    current_team.projects << project
  end

  context "proper user of a project" do
    before do
      project.users << current_user
    end

    context "for an admin" do
      let(:current_user) { create :user, :with_team_and_is_admin }

      %i[index show create new update edit destroy].each do |action|
        it { should permit(action) }
      end

      it 'lists all notes' do
        expect(policy_scope).to eq([note])
      end
    end

    context "for a user" do
      let(:current_user) { create :user, :with_team }

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
      let(:current_user) { create :user, :with_team_and_is_admin }

      %i[index show create new update edit destroy].each do |action|
        it { should permit(action) }
      end

      it 'lists all notes' do
        expect(policy_scope).to eq([note])
      end
    end

    context "for a user" do
      let(:current_user) { create :user, :with_team }

      %i[index create new update edit destroy].each do |action|
        it { should_not permit(action) }
      end

      it 'lists no notes' do
        expect(policy_scope).to eq([])
      end
    end
  end
end


