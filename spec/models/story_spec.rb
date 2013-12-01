require 'spec_helper'

describe Story do

  subject { FactoryGirl.build :story }

  describe "validations" do

    describe '#title' do
      it "is required" do
        subject.title = ''
        subject.should have(1).error_on(:title)
      end
    end

    describe '#story_type' do
      it "is required" do
        subject.story_type = nil
        subject.should have(1).error_on(:story_type)
      end

      it "is must be a valid story type" do
        subject.story_type = 'flum'
        subject.should have(1).error_on(:story_type)
      end
    end

    describe '#state' do
      it "must be a valid state" do
        subject.state = 'flum'
        subject.should have(1).error_on(:state)
      end
    end

    describe "#project" do
      it "cannot be nil" do
        subject.project_id = nil
        subject.should have(1).error_on(:project)
      end

      it "must have a valid project_id" do
        subject.project_id = "invalid"
        subject.should have(1).error_on(:project)
      end

      it "must have a project" do
        subject.project =  nil
        subject.should have(1).error_on(:project)
      end
    end

    describe '#estimate' do
      it "must be valid for the project point scale" do
        subject.project.point_scale = 'fibonacci'
        subject.estimate = 4 # not in the fibonacci series
        subject.should have(1).error_on(:estimate)
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
      it { should_not be_estimated }
    end

    context "when estimate is not nil" do
      before { subject.estimate = 0 }
      it { should be_estimated }
    end

  end

  describe "#estimable?" do

    context "when story is a feature" do
      before { subject.story_type = 'feature' }

      context "when estimate is nil" do
        before { subject.estimate = nil }
        it { should be_estimable }
      end

      context "when estimate is not nil" do
        before { subject.estimate = 0 }
        it { should_not be_estimable }
      end

    end

    ['chore', 'bug', 'release'].each do |story_type|
      specify "a #{story_type} is not estimable" do
        subject.story_type = story_type
        subject.should_not be_estimable
      end
    end

  end

  describe "#as_json" do
    before { subject.id = 42 }

    specify do
      subject.as_json['story'].keys.sort.should == [
        "title", "accepted_at", "created_at", "updated_at", "description",
        "project_id", "story_type", "owned_by_id", "requested_by_id", "estimate",
        "state", "position", "id", "errors", "labels", "notes"
      ].sort
    end
  end

  describe "#set_position_to_last" do

    context "when position is set" do
      before { subject.position = 42 }

      it "does nothing" do
        subject.set_position_to_last.should be_true
        subject.position = 42
      end
    end

    context "when there are no other stories" do
      before { subject.stub_chain(:project, :stories, :order, :first).and_return(nil) }

      it "sets position to 1" do
        subject.set_position_to_last
        subject.position.should == 1
      end
    end

    context "when there are other stories" do

      let(:last_story) { mock_model(Story, :position => 41) }

      before do
        subject.stub_chain(:project, :stories, :order, :first).and_return(last_story)
      end

      it "incrememnts the position by 1" do
        subject.set_position_to_last
        subject.position.should == 42
      end
    end
  end

  describe "#accepted_at" do

    context "when not set" do

      before { subject.accepted_at = nil }

      # FIXME This is non-deterministic
      it "gets set when state changes to 'accepted'" do
        subject.update_attribute :state, 'accepted'
        subject.accepted_at.should == Date.today
      end

    end

    context "when set" do

      before { subject.accepted_at = Date.parse('1999/01/01') }

      # FIXME This is non-deterministic
      it "is unchanged when state changes to 'accepted'" do
        subject.update_attribute :state, 'accepted'
        subject.accepted_at.should == Date.parse('1999/01/01')
      end

      it "is unset when state changes from 'accepted'" do
        subject.accepted_at = Date.parse('1999/01/01') 
        subject.update_attribute :state, 'accepted'
        subject.update_attribute :state, 'started'
        subject.accepted_at.should be_nil
      end

    end
  end

  describe "#to_csv" do

    it "returns an array" do
      subject.to_csv.should be_kind_of(Array)
    end

    it "has the same number of elements as the .csv_headers" do
      subject.to_csv.length.should == Story.csv_headers.length
    end
  end

  describe "#notify_users" do

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
      subject.notify_users.should include(requested_by)
    end

    specify do
      subject.notify_users.should include(owned_by)
    end

    specify do
      subject.notify_users.should include(note_user)
    end

    it "strips out nil values" do
      subject.requested_by = subject.owned_by = nil
      subject.notify_users.should_not include(nil)
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

    specify { Story.csv_headers.should be_kind_of(Array) }

  end
end
