require 'rails_helper'

describe TaskOperations do
  describe '::Create' do
    let!(:membership)     { create(:membership) }
    let(:user)            { User.first }
    let(:project)         { Project.first }
    let(:story)           { create(:story, project: project, requested_by: user) }

    context 'with valid params' do
      subject { ->{TaskOperations::Create.run(story.tasks.build(name: 'name'))} }

      it { expect { subject.call }.to change {Task.count} }
      it { expect { subject.call }.to change {Changeset.count} }
      it { expect(subject.call).to be_eql Task.last }
    end

    context 'with invalid params' do
      subject { ->{TaskOperations::Create.run(story.tasks.build(name: ''))} }

      it { expect { subject.call }.to_not change {Task.count} }
      it { expect(subject.call).to be_falsy }
    end
  end
end
