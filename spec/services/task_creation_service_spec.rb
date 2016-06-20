require 'rails_helper'

describe TaskCreationService do
  describe '#create' do
    let!(:membership)     { create(:membership) }
    let(:user)            { User.first }
    let(:project)         { Project.first }
    let(:story)           { create(:story, project: project, requested_by: user) }

    context 'with valid params' do
      subject { ->{TaskCreationService.create(story.tasks.build(name: 'name'))} }

      it { is_expected.to change {Task.count} }
      it { is_expected.to change {Changeset.count} }
      it { expect(subject.call).to be_eql Task.last }
    end

    context 'with invalid params' do
      subject { ->{TaskCreationService.create(story.tasks.build(name: ''))} }

      it { is_expected.to_not change {Task.count} }
      it { expect(subject.call).to be_falsy }
    end
  end
end
