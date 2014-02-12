require 'spec_helper'

describe Task do
  
  let(:project) { mock_model(Project, :suppress_notifications => true) }
  let(:story)   { mock_model(Story, :project => project) }
  
  subject { FactoryGirl.build :task, :story => story }

  describe "validations" do
    
    describe "#name" do
      before { subject.task = '' }
      it { should have(1).error_on(:task) }
    end

  end

  describe "#as_json" do

    it "returns the right keys" do
      subject.as_json["task"].keys.sort.should == %w[
        created_at done id story_id task updated_at
      ]
    end

  end
end
