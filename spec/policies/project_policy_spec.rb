require 'rails_helper'

describe ProjectPolicy do
  let(:project) { create :project }
  let(:pundit_context) { PunditContext.new(current_team, current_user, current_project: project) }
  let(:current_team) { current_user.teams.first }
  let(:policy_scope) { ProjectPolicy::Scope.new(pundit_context, Project).resolve.all }
  subject { ProjectPolicy.new(pundit_context, project) }

  let!(:archived_project) { create :project, teams: [current_team], users: [current_user], archived_at: Time.current }

  context "proper user of project and the team owns this project" do
    before do
      project.users << current_user
      current_team.ownerships.create(project: project, is_owner: true)
    end

    context "for an admin" do
      let(:current_user) { create :user, :with_team_and_is_admin }

      %i[index show create new update edit].each do |action|
        it { should permit(action) }
      end

      %i[import import_upload archive unarchive destroy share unshare transfer ownership].each do |action|
        it { should permit(action) }
      end
    end
  end

  context "proper user of a project" do
    before do
      project.users << current_user
      current_team.projects << project
    end

    context "for an admin" do
      let(:current_user) { create :user, :with_team_and_is_admin }

      %i[index show create new update edit reports archived].each do |action|
        it { should permit(action) }
      end

      %i[import import_upload archive unarchive destroy share unshare transfer ownership].each do |action|
        it { should_not permit(action) }
      end

      it 'lists all projects' do
        expect(policy_scope).to match_array([project, archived_project])
      end
    end

    context "for a user" do
      let(:current_user) { create :user, :with_team }

      %i[show reports].each do |action|
        it { should permit(action) }
      end

      %i[index create new update edit].each do |action|
        it { should_not permit(action) }
      end

      %i[import import_upload archive unarchive destroy share unshare transfer ownership].each do |action|
        it { should_not permit(action) }
      end

      it 'lists all projects' do
        expect(policy_scope).to eq([project])
      end
    end
  end

  context "user not a member of project" do
    before { current_team.projects << project }

    context "for an admin" do
      let(:current_user) { create :user, :with_team_and_is_admin }

      %i[index show create new update edit reports].each do |action|
        it { should permit(action) }
      end

      %i[import import_upload archive unarchive destroy share unshare transfer ownership].each do |action|
        it { should_not permit(action) }
      end

      it 'lists all projects' do
        expect(policy_scope).to match_array([project, archived_project])
      end
    end

    context "for a user" do
      let(:current_user) { create :user, :with_team }

      %i[index create new update edit reports].each do |action|
        it { should_not permit(action) }
      end

      %i[import import_upload archive unarchive destroy share unshare transfer ownership].each do |action|
        it { should_not permit(action) }
      end

      it 'hides project' do
        expect(policy_scope).to eq([])
      end
    end
  end
end
