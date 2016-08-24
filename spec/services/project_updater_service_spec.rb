require 'rails_helper'

describe ProjectUpdaterService do
  describe '#save' do
    let(:user)           { create(:user) }
    let(:project_params) { { name: 'Foo bar', start_date: Date.today } }
    let(:project)        { user.projects.build(project_params) }

    context 'with valid params' do
      subject { ->{ProjectUpdaterService.save(project)} }

      it { is_expected.to change {Project.count} }
      it { expect(subject.call).to be_eql Project.last }
    end

    context 'with invalid params' do
      before { project.name = nil }

      subject { ->{ProjectUpdaterService.save(project)} }

      it { is_expected.to_not change {Project.count} }
      it { expect(subject.call).to be_falsy }
    end
  end
end
