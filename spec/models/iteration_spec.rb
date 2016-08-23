require 'rails_helper'

describe Iteration do
  let(:user) { create(:user) }
  let(:project) { create(:project) }
  let(:service) { IterationService.new(project) }

  subject { Iteration.new(service, 1, 2) }

  before do
    project.users << user
    project.suppress_notifications = true
  end

  describe '#points' do
        it 'should not allow bug/chore story to be estimated' do
      # this is in the beforeEach of iteration_spec.js, that's why we're double checking it here
      expect {
        subject << create(:story, project: project, estimate: 3, story_type: 'bug', state: 'accepted', requested_by: user)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should calculate its points' do
      subject << create(:story, project: project, estimate: 2, story_type: 'feature', requested_by: user)
      subject << create(:story, project: project, estimate: 3, story_type: 'feature', state: 'accepted', requested_by: user)

      expect(subject.points).to eq(5)
    end

    it 'should return 0 for points if it has no stories' do
      expect(subject.points).to eq(0)
    end

    it 'should report how many points it overflows by' do
      # Should return 0 if the iteration points are less than maximum_points
      expect(subject).to receive(:points).and_return(1)
      expect(subject.overflows_by).to eq(0)

      # Should return 0 if the iteration points are equal to maximum_points
      expect(subject).to receive(:points).and_return(2)
      expect(subject.overflows_by).to eq(0)

      # Should return the difference if iteration points are greater than
      # maximum_points
      expect(subject).to receive(:points).and_return(5)
      expect(subject.overflows_by).to eq(3)
    end
  end

  describe 'filling backlog iterations' do
    it 'should return how many points are available' do
      expect(subject).to receive(:maximum_points).and_return(5)
      expect(subject).to receive(:points).and_return(3)
      expect(subject.available_points).to eq(2)
    end

    it 'should always accept chores bugs and releases' do
      story = build(:story)

      %w(chore bug release).each do |story_type|
        story.story_type = story_type
        expect(subject.can_take_story?(story)).to be_truthy
      end
    end

    it 'should not accept anything when isFull is true' do
      story = build(:story)

      subject.instance_variable_set('@is_full', true) # I know, this is ugly

      %w(chore bug release).each do |story_type|
        story.story_type = story_type
        expect(subject.can_take_story?(story)).to be_falsey
      end
    end

    it 'should accept a feature if there are enough free points' do
      allow(subject).to receive(:available_points).and_return(3)
      allow(subject).to receive(:points).and_return(1)

      story = build(:story, story_type: 'feature', estimate: 3)

      expect(subject.can_take_story?(story)).to be_truthy

      expect(story).to receive(:estimate).and_return(4)
      expect(subject.can_take_story?(story)).to be_falsey
    end

    it 'should always take at least one feature no matter how big' do
      allow(subject).to receive(:available_points).and_return(1)
      allow(subject).to receive(:points).and_return(0)

      story = build(:story, story_type: 'feature', estimate: 2)

      expect(subject.can_take_story?(story)).to be_truthy
    end
  end
end
