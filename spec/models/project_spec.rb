require 'spec_helper'

describe Project do


  subject { FactoryGirl.build :project }


  describe "validations" do

    describe "#name" do
      before { subject.name = '' }
      it { should have(1).error_on(:name) }
    end

    describe "#default_velocity" do
      it "must be greater than 0" do
        subject.default_velocity = 0
        subject.should have(1).error_on(:default_velocity)
      end

      it "must be an integer" do
        subject.default_velocity = 0
        subject.should have(1).error_on(:default_velocity)
      end
    end

    describe "#point_scale" do
      before { subject.point_scale = 'invalid_point_scale' }
      it { should have(1).error_on(:point_scale) }
    end

    describe "#iteration_length" do
      it "must be greater than 0" do
        subject.iteration_length = 0
        subject.should have(1).error_on(:iteration_length)
      end

      it "must be less than 5" do
        subject.iteration_length = 0
        subject.should have(1).error_on(:iteration_length)
      end

      it "must be an integer" do
        subject.iteration_length = 2.5
        subject.should have(1).error_on(:iteration_length)
      end
    end

    describe "#iteration_start_day" do
      it "must be greater than -1" do
        subject.iteration_start_day = -1
        subject.should have(1).error_on(:iteration_start_day)
      end

      it "must be less than 6" do
        subject.iteration_start_day = 7
        subject.should have(1).error_on(:iteration_start_day)
      end

      it "must be an integer" do
        subject.iteration_start_day = 2.5
        subject.should have(1).error_on(:iteration_start_day)
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
      lambda do
        @project.destroy
      end.should change(Story, :count).by(-1)
    end

    specify "changesets" do
      lambda do
        @project.destroy
      end.should change(Changeset, :count).by(-1)
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
        subject.stub_chain(:changesets).and_return([])
      end

      its(:last_changeset_id) { should be_nil }
    end

    context "when there are changesets" do

      let(:changeset) { double("changeset", :id => 42) }

      before do
        subject.stub(:changesets).and_return([nil, nil, changeset])
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
      project.stories.first.state.should == 'accepted'
    end

    it 'converts story type to lowercase before creating the story' do
      csv_string << "My Story,Chore,#{user.name},#{user.name},unscheduled"

      project.stories.from_csv csv_string
      project.stories.first.story_type.should == 'chore'
    end
  end

  describe "#csv_filename" do
    subject { FactoryGirl.build(:project, :name => 'Test Project') }

    its(:csv_filename) { should match(/^Test Project-\d{8}_\d{4}\.csv$/) }
  end

  describe "#as_json" do
    subject { FactoryGirl.create :project }

    (Project::JSON_ATTRIBUTES + Project::JSON_METHODS).each do |key|
      its(:as_json) { subject.as_json['project'].should have_key(key) }
    end
  end

end
