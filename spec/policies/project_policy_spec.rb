require 'rails_helper'

describe ProjectPolicy do
  let(:project) { create :project }
  let(:pundit_context) { PunditContext.new(current_user) }
  subject { ProjectPolicy.new(pundit_context, project) }

  context "proper user of a project" do
    before do
      project.users << current_user
    end

    context "for an admin" do
      let(:current_user) { create :user, name: 'admin', is_admin: true }

      it { should permit(:index) }
      it { should permit(:show) }
      it { should permit(:create) }
      it { should permit(:new) }
      it { should permit(:update) }
      it { should permit(:edit) }
      it { should permit(:destroy) }
    end

    context "for a user" do
      let(:current_user) { create :user, is_admin: false }

      it { should_not permit(:index) }
      it { should permit(:show) }
      it { should_not permit(:create) }
      it { should_not permit(:new) }
      it { should_not permit(:update) }
      it { should_not permit(:edit) }
      it { should_not permit(:destroy) }
    end
  end

  context "user not a member of project" do
    context "for an admin" do
      let(:current_user) { create :user, name: 'admin', is_admin: true }

      it { should permit(:index) }
      it { should_not permit(:show) }
      it { should permit(:create) }
      it { should permit(:new) }
      it { should permit(:update) }
      it { should permit(:edit) }
      it { should permit(:destroy) }
    end

    context "for a user" do
      let(:current_user) { create :user, is_admin: false }

      it { should_not permit(:index) }
      it { should_not permit(:show) }
      it { should_not permit(:create) }
      it { should_not permit(:new) }
      it { should_not permit(:update) }
      it { should_not permit(:edit) }
      it { should_not permit(:destroy) }
    end
  end
end
