require 'rails_helper'

describe UserPolicy do
  let(:other_member) { create :user, name: 'Anyone' }
  let(:project) { create :project }
  let(:pundit_context) { PunditContext.new(current_team, current_user, current_project: project) }
  let(:current_team) { current_user.teams.first }
  let(:policy_scope) { UserPolicy::Scope.new(pundit_context, User).resolve.all }
  subject { UserPolicy.new(pundit_context, other_member) }

  before { project.users << other_member }

  context "proper user of a project" do
    before do
      project.users << current_user
      current_team.projects << project
    end

    context "for an admin" do
      let(:current_user) { create :user, :with_team_and_is_admin }

      %i[index show create new update edit destroy].each do |action|
        it { should permit(action) }
      end

      it 'lists all members' do
        expect(policy_scope.sort).to eq([other_member, current_user].sort)
      end
    end

    context "for a user but not acting on himself" do
      let(:current_user) { create :user, :with_team }

      it { should permit(:index) }
      it { should permit(:show) }

      %i[create new update edit destroy].each do |action|
        it { should_not permit(action) }
      end

      it 'lists all members' do
        expect(policy_scope.pluck(:id).sort).to eq([other_member.id, current_user.id].sort)
      end
    end

    context "for a user acting on himself" do
      let(:current_user) { create :user, :with_team }
      subject { UserPolicy.new(pundit_context, current_user) }

      it { should permit(:new) }
      it { should permit(:create) }
      it { should permit(:destroy) }

      it { should permit(:edit) }
      it { should permit(:update) }
    end
  end

  context "user not a member of project" do
    context "for an admin" do
      let(:current_user) { create :user, :with_team_and_is_admin }

      %i[index show create new update edit destroy].each do |action|
        it { should permit(action) }
      end

      it 'lists all members' do
        expect(policy_scope.pluck(:id)).to eq([other_member.id])
      end
    end

    context "for a user" do
      let(:current_user) { create :user, :with_team }

      %i[index create new update edit destroy].each do |action|
        it { should_not permit(action) }
      end

      it 'hides project' do
        expect(policy_scope).to eq([])
      end
    end
  end
end

