require 'rails_helper'

describe Story do

  subject { build :story, :with_project }

  describe 'scopes' do
    let!(:story) { create(:story, :with_project, labels: 'feature,test') }
    let!(:dummy_story) { create(:story, :with_project, labels: 'something') }

    describe '#by_label' do
      it 'find when label contains in story labels' do
        expect(described_class.by_label('test')).to include story
      end

      it 'return empty when label is not included in story labels' do
        expect(described_class.by_label('test')).to_not include dummy_story
      end
    end
  end

  describe "validations" do

    describe '#title' do
      it "is required" do
        subject.title = ''
        subject.valid?
        expect(subject.errors[:title].size).to eq(1)
      end
    end

    describe '#story_type' do
      it "is required" do
        subject.story_type = nil
        subject.valid?
        expect(subject.errors[:story_type].size).to eq(1)
      end

      it "is must be a valid story type" do
        subject.story_type = 'flum'
        subject.valid?
        expect(subject.errors[:story_type].size).to eq(1)
      end
    end

    describe '#state' do
      it "must be a valid state" do
        subject.state = 'flum'
        subject.valid?
        expect(subject.errors[:state].size).to eq(1)
      end
    end

    describe "#project" do
      it "cannot be nil" do
        subject.project_id = nil
        subject.valid?
        expect(subject.errors[:project].size).to eq(1)
      end

      it "must have a valid project_id" do
        subject.project_id = "invalid"
        subject.valid?
        expect(subject.errors[:project].size).to eq(1)
      end

      it "must have a project" do
        subject.project =  nil
        subject.valid?
        expect(subject.errors[:project].size).to eq(1)
      end
    end

    describe '#estimate' do
      before do
        subject.project.users = [ subject.requested_by ]
      end

      it "must be valid for the project point scale" do
        subject.project.point_scale = 'fibonacci'
        subject.estimate = 4 # not in the fibonacci series
        subject.valid?
        expect(subject.errors[:estimate].size).to eq(1)
      end

      it "must be invalid for bug stories" do
        subject.story_type = 'bug'
        subject.estimate = 2

        expect(subject).to_not be_valid
      end

      it "must be invalid for chore stories" do
        subject.story_type = 'chore'
        subject.estimate = 1

        expect(subject).to_not be_valid
      end
    end

  end

  describe 'associations' do
    describe 'notes' do
      let!(:user)  { FactoryGirl.create :user }
      let!(:project) { FactoryGirl.create :project, users: [user] }
      let!(:story) { FactoryGirl.create :story, project: project, requested_by: user }
      let!(:note) { FactoryGirl.create(:note, created_at: Date.current + 2.days, user: user, story: story) }
      let!(:note2) { FactoryGirl.create(:note, created_at: Date.current, user: user, story: story) }

      it 'order by created at' do
        story.reload

        expect(story.notes).to eq [note2, note]
      end
    end
  end

  describe "defaults" do

    subject { Story.new }

    its(:state)       { should == "unstarted" }
    its(:story_type)  { should == "feature" }

  end

  describe "#to_s" do

    before { subject.title = "Dummy Title" }
    its(:to_s) { should == "Dummy Title" }

  end

  describe "#estimated?" do

    context "when estimate is nil" do
      before { subject.estimate = nil }
      it { is_expected.not_to be_estimated }
    end

    context "when estimate is not nil" do
      before { subject.estimate = 0 }
      it { is_expected.to be_estimated }
    end

  end

  describe "#estimable?" do

    context "when story is a feature" do
      before { subject.story_type = 'feature' }

      context "when estimate is nil" do
        before { subject.estimate = nil }
        it { is_expected.to be_estimable }
      end

      context "when estimate is not nil" do
        before { subject.estimate = 0 }
        it { is_expected.not_to be_estimable }
      end

    end

    ['chore', 'bug', 'release'].each do |story_type|
      specify "a #{story_type} is not estimable" do
        subject.story_type = story_type
        expect(subject).not_to be_estimable
      end
    end

  end

  describe "#as_json" do
    before { subject.id = 42 }

    specify do
      expect(subject.as_json['story'].keys.sort).to eq([
        "title", "accepted_at", "created_at", "updated_at", "description",
        "project_id", "story_type", "owned_by_id", "requested_by_id",
        "requested_by_name", "owned_by_name", "owned_by_initials", "estimate",
        "state", "position", "id", "errors", "labels", "notes", "tasks", "documents"
      ].sort)
    end
  end

  describe "#set_position_to_last" do

    context "when position is set" do
      before { subject.position = 42 }

      it "does nothing" do
        expect(subject.set_position_to_last).to be true
        subject.position = 42
      end
    end

    context "when there are no other stories" do
      before { allow(subject).to receive_message_chain(:project, :stories, :order, :first).and_return(nil) }

      it "sets position to 1" do
        subject.set_position_to_last
        expect(subject.position).to eq(1)
      end
    end

    context "when there are other stories" do

      let(:last_story) { mock_model(Story, :position => 41) }

      before do
        allow(subject).to receive_message_chain(:project, :stories, :order, :first).and_return(last_story)
      end

      it "incrememnts the position by 1" do
        subject.set_position_to_last
        expect(subject.position).to eq(42)
      end
    end
  end

  describe "#accepted_at" do

    context "when not set" do

      before { subject.accepted_at = nil }

      # FIXME This is non-deterministic
      it "gets set when state changes to 'accepted'" do
        subject.update_attribute :state, 'accepted'
        expect(subject.accepted_at).to eq(Date.today)
      end

    end

    context "when set" do

      before { subject.accepted_at = Date.parse('1999/01/01') }

      # FIXME This is non-deterministic
      it "is unchanged when state changes to 'accepted'" do
        subject.update_attribute :state, 'accepted'
        expect(subject.accepted_at).to eq(Date.parse('1999/01/01'))
      end

      it "is unset when state changes from 'accepted'" do
        subject.accepted_at = Date.parse('1999/01/01')
        subject.update_attribute :state, 'accepted'
        subject.update_attribute :state, 'started'
        expect(subject.accepted_at).to be_nil
      end

    end
  end

  describe "#to_csv" do

    it "returns an array" do
      expect(subject.to_csv).to be_kind_of(Array)
    end

    it "has the same number of elements as the .csv_headers" do
      expect(subject.to_csv.length).to eq(Story.csv_headers.length)
    end
  end

  describe "#stakeholders_users" do

    let(:requested_by)  { mock_model(User) }
    let(:owned_by)      { mock_model(User) }
    let(:note_user)     { mock_model(User) }
    let(:notes)         { [mock_model(Note, :user => note_user)] }

    before do
      subject.requested_by  = requested_by
      subject.owned_by      = owned_by
      subject.notes         = notes
    end

    specify do
      expect(subject.stakeholders_users).to include(requested_by)
    end

    specify do
      expect(subject.stakeholders_users).to include(owned_by)
    end

    specify do
      expect(subject.stakeholders_users).to include(note_user)
    end

    it "strips out nil values" do
      subject.requested_by = subject.owned_by = nil
      expect(subject.stakeholders_users).not_to include(nil)
    end
  end

  context "when unscheduled" do
    before { subject.state = 'unscheduled' }
    its(:events)  { should == [:start] }
    its(:column)  { should == '#chilly_bin' }
  end

  context "when unstarted" do
    before { subject.state = 'unstarted' }
    its(:events)  { should == [:start] }
    its(:column)  { should == '#backlog' }
  end

  context "when started" do
    before { subject.state = 'started' }
    its(:events)  { should == [:finish] }
    its(:column)  { should == '#in_progress' }
  end

  context "when finished" do
    before { subject.state = 'finished' }
    its(:events)  { should == [:deliver] }
    its(:column)  { should == '#in_progress' }
  end

  context "when delivered" do
    before { subject.state = 'delivered' }
    its(:events)  { should include(:accept) }
    its(:events)  { should include(:reject) }
    its(:column)  { should == '#in_progress' }
  end

  context "when rejected" do
    before { subject.state = 'rejected' }
    its(:events)  { should == [:restart] }
    its(:column)  { should == '#in_progress' }
  end

  context "when accepted" do
    before { subject.state = 'accepted' }
    its(:events)  { should == [] }
    its(:column)  { should == '#done' }
  end


  describe '.csv_headers' do

    specify { expect(Story.csv_headers).to be_kind_of(Array) }

  end
end
