require 'rails_helper'

describe Note do

  let(:project) { mock_model(Project, :suppress_notifications => true) }
  let(:user)    { mock_model(User) }
  let(:story)   { mock_model(Story, :project => project) }

  subject { FactoryGirl.build :note, :story => story, :user => user }

  describe "validations" do

    describe "#name" do
      before { subject.note = '' }
      it "should have an error on note" do
        subject.valid?
        expect(subject.errors[:note].size).to eq(1)
      end
    end

  end

  describe "#as_json" do

    it "returns the right keys" do
      expect(subject.as_json["note"].keys.sort).to eq(%w[
        created_at errors id note story_id updated_at user_id user_name
      ])
    end

  end

  describe "#to_s" do
    before do
      subject.note = "Test note"
      subject.created_at = "Nov 3, 2011"
      allow(user).to receive_messages(:name => 'user')
    end

    its(:to_s)  { should == "Test note (user - Nov 03, 2011)" }
  end
end
