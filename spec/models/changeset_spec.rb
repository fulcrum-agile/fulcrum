require 'spec_helper'

describe Changeset do

  describe "validations" do

    it "must have a story" do
      subject.story = nil
      subject.should have(1).error_on(:story_id)
    end

  end

  describe "#project_id" do

    context "when project_id is blank" do

      let(:user)    { Factory.create(:user) }
      let(:project) { Factory.create(:project, :users => [user]) }
      let(:story)   { Factory.create(:story, :project => project,
                                     :requested_by => user) }

      subject do
        Factory.create :changeset, :story => story, :project_id => nil
      end

      it { should have(0).errors_on(:project_id) }
      its(:project) { should == project }

    end

  end

  describe ".since" do
    specify do
      Changeset.since(234).where_values.first.should == 'id > 234'
    end
  end
end
