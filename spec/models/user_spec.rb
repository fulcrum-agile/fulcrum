require 'rails_helper'

describe User do

  describe "validations" do
    
    it "requires a name" do
      subject.name = ''
      subject.valid?
      expect(subject.errors[:name].size).to eq(1)
    end

    it "requires initials" do
      subject.initials = ''
      subject.valid?
      expect(subject.errors[:initials].size).to eq(1)
    end

  end


  describe "#to_s" do

    subject { FactoryGirl.build(:user, :name => "Dummy User", :initials => "DU",
                                    :email => "dummy@example.com") }

    its(:to_s) { should == "Dummy User (DU) <dummy@example.com>" }

  end

  describe "#as_json" do

    before do
      subject.id = 42
    end

    specify {
      expect(subject.as_json['user'].keys.sort).to eq(
        %w[email id initials name username]
      )
    }

  end

  describe "#remove_story_association" do
    let(:user) { FactoryGirl.create :user}
    let(:project) { FactoryGirl.build :project }
    let(:story) { FactoryGirl.build :story, project: project }

    before do
      project.users << user
      project.save
      story.owned_by = user
      story.requested_by = user
      story.save
    end

    it 'removes the story owner and requester when the user is destroyed' do
      expect{ user.destroy }.to change{Membership.count}.by(-1)
      story.reload
      expect(story.owned_by).to be_nil
      expect(story.requested_by).to be_nil
    end
  end

end
