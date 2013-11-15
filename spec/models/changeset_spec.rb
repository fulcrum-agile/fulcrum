require 'spec_helper'

describe Changeset do

  describe "validations" do

    it "must have a story" do
      subject.story = nil
      subject.should have(1).error_on(:story)
    end

    describe "associations" do
      let(:user)    { FactoryGirl.create(:user) }
      let(:project) { FactoryGirl.create(:project, :users => [user]) }
      let(:story)   { FactoryGirl.create(:story, :project => project,
                                     :requested_by => user) }
      let(:changeset) { FactoryGirl.create :changeset, :story => story, :project => project }

      it "must have a valid project" do
        changeset.project_id = "invalid"
        changeset.should have(1).errors_on(:project)
      end

      it "must have a valid story" do
        changeset.story_id = "invalid"
        changeset.should have(1).errors_on(:story)
      end
    end
  end

  describe "#project_id" do

    context "when project_id is blank" do

      let(:user)    { FactoryGirl.create(:user) }
      let(:project) { FactoryGirl.create(:project, :users => [user]) }
      let(:story)   { FactoryGirl.create(:story, :project => project,
                                     :requested_by => user) }

      subject do
        FactoryGirl.create :changeset, :story => story, :project => nil
      end

      it { should have(0).errors_on(:project) }
      its(:project) { should == project }

    end

  end

  describe ".since" do
    specify do
      Changeset.since(234).where_values.first.should == 'id > 234'
    end
  end
end
