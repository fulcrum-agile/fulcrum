require 'rails_helper'

describe ProjectOperations do
  let(:user)           { create(:user) }
  let(:project_params) { { name: 'Foo bar', start_date: Date.today } }
  let(:project) { user.projects.build(project_params) }

  describe 'Create' do

    context 'with valid params' do
      subject { ->{ProjectOperations::Create.run(project)} }

      it { expect { subject.call }.to change { Project.count } }
      it { expect(subject.call).to be_eql Project.last }
    end

    context 'with invalid params' do
      before { project.name = nil }

      subject { ->{ProjectOperations::Create.run(project)} }

      it { is_expected.to_not change {Project.count} }
      it { expect(subject.call).to be_falsy }
    end
  end

  describe 'Update' do
    before { project.save! }

    context 'with valid params' do
      subject { ->{ProjectOperations::Update.run(project, { name: 'Hello World' })} }

      it { expect { subject.call }.to_not change {Project.count} }
      it { expect(subject.call.name).to be_eql 'Hello World' }
    end

    context 'with invalid params' do
      before { project.name = nil }

      subject { ->{ProjectOperations::Update.run(project, { name: nil })} }

      it { expect(subject.call).to be_falsy }
    end
  end

  describe 'Destroy' do
    before { project.save! }

    subject { ->{ProjectOperations::Destroy.run(project)} }

    it { expect { subject.call }.to change {Project.count}.by(-1) }
  end
end
