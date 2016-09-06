require 'rails_helper'

describe TeamPolicy do
  let(:pundit_context) { PunditContext.new(current_team, current_user) }
  let(:current_team) { current_user.teams.first }
  let(:policy_scope) { TeamPolicy::Scope.new(pundit_context, Team).resolve.all }
  subject { TeamPolicy.new(pundit_context, current_team) }

  context "proper user of a team" do
    context "for an admin" do
      let(:current_user) { create :user, :with_team_and_is_admin }

      %i[index show create new update edit destroy].each do |action|
        it { should permit(action) }
      end

      it 'lists all teams' do
        expect(policy_scope).to eq([ current_team ])
      end
    end

    context "for a user" do
      let(:current_user) { create :user, :with_team }

      %i[create new].each do |action|
        it { should permit(action) }
      end

      %i[index update edit destroy].each do |action|
        it { should_not permit(action) }
      end

      it 'lists all teams' do
        expect(policy_scope).to eq([])
      end
    end
  end
end
