require 'rails_helper'

describe TeamOperations do
  let(:team_params) { { name: 'Test Team' } }
  let(:team) { Team.new(team_params) }

  describe 'Create' do

    context 'with valid params' do
      subject { ->{TeamOperations::Create.(team, nil)} }

      it { expect { subject.call }.to change { Team.count }.by(1) }
      it { expect(subject.call).to be_eql Team.last }
    end

    context 'with invalid params' do
      before { team.name = nil }

      subject { ->{TeamOperations::Create.(team, nil)} }

      it { is_expected.to_not change {Team.count} }
      it { expect(subject.call).to be_falsy }
    end
  end

  describe 'Update' do
    before { team.save! }

    context 'with valid params' do
      subject { ->{TeamOperations::Update.(team, { name: 'Hello World' }, nil )} }

      it { expect { subject.call }.to_not change {Team.count} }
      it { expect(subject.call.name).to be_eql 'Hello World' }
    end

    context 'with invalid params' do
      before { team.name = nil }

      subject { ->{TeamOperations::Update.(team, { name: nil }, nil)} }

      it { expect(subject.call).to be_falsy }
    end
  end

  describe 'Destroy' do
    before { team.save! }

    subject { ->{TeamOperations::Destroy.(team, nil)} }

    it { expect(subject.call.archived_at).to_not be_nil }
  end
end

