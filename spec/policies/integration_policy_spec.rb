require 'rails_helper'

describe IntegrationPolicy do
  let(:other_member) { create :user, name: 'Anyone' }
  let(:integration) { create :integration, project: project }
  let(:project) { create :project }
  let(:pundit_context) { PunditContext.new(current_user, current_project: project) }
  let(:policy_scope) { IntegrationPolicy::Scope.new(pundit_context, Integration).resolve.all }

  subject { IntegrationPolicy.new(pundit_context, integration) }

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

      it 'lists all integrations of the project' do
        expect(policy_scope).to eq([integration])
      end
    end

    context "for a user" do
      let(:current_user) { create :user, is_admin: false }

      %i[index show create new update edit destroy].each do |action|
        it { should_not permit(action) }
      end

      it 'hides integrations of the project' do
        expect(policy_scope).to eq([])
      end
    end

  end

  context "user not a member of project" do
    context "for an admin" do
      let(:current_user) { create :user, name: 'admin', is_admin: true }

      %i[index show create new update edit destroy].each do |action|
        it { should permit(action) }
      end

      it 'lists all integrations of the project' do
        expect(policy_scope).to eq([integration])
      end
    end

    context "for a user" do
      let(:current_user) { create :user, is_admin: false }

      %i[index create new update edit destroy].each do |action|
        it { should_not permit(action) }
      end

      it 'hides integrations of the project' do
        expect(policy_scope).to eq([])
      end
    end
  end
end


