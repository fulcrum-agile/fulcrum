require 'spec_helper'

describe Note do

  let(:user)    { Factory.create(:user) }
  let(:project) { Factory.create(:project, :users => [user]) }
  let(:story)   { Factory.create(:story, :project => project, :requested_by => user) }
  let(:mailer)  { mock("mailer") }

  subject(:note) { Factory.build(:note, :story => story, :user => user) }

  describe "validations" do
    it { should validate_presence_of(:note) }
  end

  describe "when saved" do

    it "executes the callback :create_changeset" do
      note.should_receive(:create_changeset)
      note.save
    end

    it "creates a changeset on the story" do
      expect{ note.save }.to change(story.changesets, :count).by(1)
    end

    it "sends notifications to all the stakeholders except the user who made the note." do
      other_user = Factory.create(:user)
      other_note = Factory.create(:note, :story => story, :user => other_user)

      Notifications.should_receive(:new_note).with(note, [other_user]).and_return(mailer)
      mailer.should_receive(:deliver)
      note.save
    end

    it "does not send notifications if the user who made the note is the only stakeholder" do
      Notifications.should_not_receive(:new_note)
      note.save
    end

    context "with project notifications turned OFF" do
      it "does not send notifications" do
        project.suppress_notifications = true
        Notifications.should_not_receive(:new_note)
        note.save
      end
    end
  end

  describe "#as_json" do

    it "returns the right keys" do
      subject.as_json["note"].keys.sort.should == %w[
        created_at errors id note story_id updated_at user_id
      ]
    end

  end

  describe "#to_s" do
    before do
      subject.note = "Test note"
      subject.created_at = "Nov 3, 2011"
      user.stub(:name => 'user')
    end

    its(:to_s)  { should == "Test note (user - Nov 03, 2011)" }
  end
end
