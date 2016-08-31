require 'rails_helper'

describe ProjectOperations do
  let(:user)           { create(:user) }
  let(:project_params) { { name: 'Foo bar', start_date: Date.current } }
  let(:project) { user.projects.build(project_params) }

  describe 'Create' do

    context 'with valid params' do
      subject { ->{ProjectOperations::Create.(project, user)} }

      it { expect { subject.call }.to change { Project.count } }
      it { expect(subject.call).to be_eql Project.last }
    end

    context 'with invalid params' do
      before { project.name = nil }

      subject { ->{ProjectOperations::Create.(project, user)} }

      it { is_expected.to_not change {Project.count} }
      it { expect(subject.call).to be_falsy }
    end
  end

  describe 'Update' do
    before { project.save! }

    context 'with valid params' do
      subject { ->{ProjectOperations::Update.(project, { name: 'Hello World' }, user )} }

      it { expect { subject.call }.to_not change {Project.count} }
      it { expect(subject.call.name).to be_eql 'Hello World' }
    end

    context 'with invalid params' do
      before { project.name = nil }

      subject { ->{ProjectOperations::Update.(project, { name: nil }, user)} }

      it { expect(subject.call).to be_falsy }
    end
  end

  describe 'Destroy' do
    before { project.save! }

    subject { ->{ProjectOperations::Destroy.(project, user)} }

    it { expect { subject.call }.to change {Project.count}.by(-1) }
  end

  describe '::ActivityRecording' do
    context 'Create' do
      subject { ->{ProjectOperations::Create.(project, user )} }

      it 'must record an activity' do
        expect { subject.call }.to change {Activity.count}
        activity = Activity.last
        expect(activity.action).to eq('create')
        expect(activity.subject).to eq(project)
        expect(activity.subject_changes).to eq({})
      end
    end

    context 'Update' do
      before { project.save! }

      subject { ->{ProjectOperations::Update.(project, { name: 'Hello World', point_scale: 'linear', iteration_start_day: 4 }, user )} }

      it 'must record an activity' do
        expect { subject.call }.to change {Activity.count}
        activity = Activity.last
        expect(activity.action).to eq('update')
        expect(activity.subject).to eq(project)
        activity.subject_changes.delete('updated_at')
        expect(activity.subject_changes).to eq({"name"=>["Foo bar", "Hello World"], "point_scale"=>["fibonacci", "linear"], "iteration_start_day"=>[1, 4]})
      end
    end


    context 'Destroy' do
      before { project.save! }

      subject { ->{ProjectOperations::Destroy.(project, user)} }

      it 'must record an activity' do
        old_attributes = project.attributes

        expect { subject.call }.to change {Activity.count}
        activity = Activity.last
        expect(activity.action).to eq('destroy')
        expect(activity.subject).to eq(nil)
        expect(activity.subject_destroyed_type).to eq('Project')
        expect(activity.subject_changes).to eq(old_attributes)
      end
    end
  end
end
