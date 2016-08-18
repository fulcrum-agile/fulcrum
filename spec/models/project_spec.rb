require 'rails_helper'

describe Project do


  subject { FactoryGirl.build :project }


  describe "validations" do

    describe "#name" do
      before { subject.name = '' }
      it "should have an error on name" do
        subject.valid?
        expect(subject.errors[:name].size).to eq(1)
      end
    end

    describe "#default_velocity" do
      it "must be greater than 0" do
        subject.default_velocity = 0
        subject.valid?
        expect(subject.errors[:default_velocity].size).to eq(1)
      end

      it "must be an integer" do
        subject.default_velocity = 0
        subject.valid?
        expect(subject.errors[:default_velocity].size).to eq(1)
      end
    end

    describe "#point_scale" do
      before { subject.point_scale = 'invalid_point_scale' }
      it "has an error on point scale" do
        subject.valid?
        expect(subject.errors[:point_scale].size).to eq(1)
      end
    end

    describe "#iteration_length" do
      it "must be greater than 0" do
        subject.iteration_length = 0
        subject.valid?
        expect(subject.errors[:iteration_length].size).to eq(1)
      end

      it "must be less than 5" do
        subject.iteration_length = 0
        subject.valid?
        expect(subject.errors[:iteration_length].size).to eq(1)
      end

      it "must be an integer" do
        subject.iteration_length = 2.5
        subject.valid?
        expect(subject.errors[:iteration_length].size).to eq(1)
      end
    end

    describe "#iteration_start_day" do
      it "must be greater than -1" do
        subject.iteration_start_day = -1
        subject.valid?
        expect(subject.errors[:iteration_start_day].size).to eq(1)
      end

      it "must be less than 6" do
        subject.iteration_start_day = 7
        subject.valid?
        expect(subject.errors[:iteration_start_day].size).to eq(1)
      end

      it "must be an integer" do
        subject.iteration_start_day = 2.5
        subject.valid?
        expect(subject.errors[:iteration_start_day].size).to eq(1)
      end
    end

  end


  describe "defaults" do
    subject { Project.new }

    its(:point_scale)             { should == 'fibonacci' }
    its(:default_velocity)        { should == 10 }
    its(:iteration_length)        { should == 1 }
    its(:iteration_start_day)     { should == 1 }
    its(:suppress_notifications)  { should == false }
  end


  describe "cascade deletes" do

    before do
      @user     = FactoryGirl.create(:user)
      @project  = FactoryGirl.create(:project, :users => [@user])
      @story    = FactoryGirl.create(:story, :project => @project,
                                 :requested_by => @user)
    end

    specify "stories" do
      expect do
        @project.destroy
      end.to change(Story, :count).by(-1)
    end
  end


  describe "#to_s" do
    subject { FactoryGirl.build :project, :name => 'Test Name' }

    its(:to_s) { should == 'Test Name' }
  end

  describe "#point_values" do
    its(:point_values) { should == Project::POINT_SCALES['fibonacci'] }
  end

  describe "#last_changeset_id" do
    context "when there are no changesets" do
      before do
        allow(subject).to receive_message_chain(:changesets).and_return([])
      end

      its(:last_changeset_id) { should be_nil }
    end

    context "when there are changesets" do

      let(:changeset) { double("changeset", :id => 42) }

      before do
        allow(subject).to receive(:changesets).and_return([nil, nil, changeset])
      end

      its(:last_changeset_id) { should == changeset.id }
    end
  end

  describe 'CSV import' do
    let(:project) { FactoryGirl.create :project }
    let(:user) do
      FactoryGirl.create(:user).tap do |user|
        # project.users << user
      end
    end
    let(:csv_string) { "Title,Story Type,Requested By,Owned By,Current State\n" }

    it 'converts state to lowercase before creating the story' do
      csv_string << "My Story,feature,#{user.name},#{user.name},Accepted"

      project.stories.from_csv csv_string
      expect(project.stories.first.state).to eq('accepted')
    end

    it 'converts story type to lowercase before creating the story' do
      csv_string << "My Story,Chore,#{user.name},#{user.name},unscheduled"

      project.stories.from_csv csv_string
      expect(project.stories.first.story_type).to eq('chore')
    end
  end

  describe "#csv_filename" do
    subject { FactoryGirl.build(:project, :name => 'Test Project') }

    its(:csv_filename) { should match(/^Test Project-\d{8}_\d{4}\.csv$/) }
  end

  describe "#as_json" do
    subject { FactoryGirl.create :project }

    (Project::JSON_ATTRIBUTES + Project::JSON_METHODS).each do |key|
      its(:as_json) { expect(subject.as_json['project']).to have_key(key) }
    end
  end

  describe "#archive" do
    subject { FactoryGirl.build :project }

    it 'sets the archived_at datetime' do
      subject.update_attributes(archived: "1")
      expect(subject.archived_at).to_not be_nil
    end

    it 'resets the archived_at datetime' do
      subject.update_attributes(archived_at: Time.zone.now)
      subject.update_attributes(archived: "0")
      expect(subject.archived_at).to be_nil
    end
  end

  describe '.archived' do
    let(:normal_project) { FactoryGirl.create :project }
    let(:archived_project) { FactoryGirl.create :project,
      archived_at: Time.current }
    subject { described_class.archived }

    it 'includes archived projects' do
      expect(subject).to include archived_project
    end

    it 'excludes non-archived projects' do
      expect(subject).not_to include normal_project
    end
  end

end
