require 'spec_helper'

describe Note do

  let(:project) { mock_model(Project, :suppress_notifications => true) }
  let(:user)    { mock_model(User) }
  let(:story)   { mock_model(Story, :project => project) }

  subject { FactoryGirl.build :note, :story => story, :user => user }

  describe "validations" do

    describe "#name" do
      before { subject.note = '' }
      it { should have(1).error_on(:note) }
    end

  end

  describe "#create_changeset" do

    let(:changesets)  { double("changesets" ) }

    before do
      changesets.should_receive(:create!)
      story.stub(:changesets  => changesets)
      story.stub(:project     => project)
    end

    it "creates a changeset on the story" do
      subject.create_changeset
    end

    context "when suppress_notifications is off" do

      let(:user1)         { mock_model(User) }
      let(:notify_users)  { [user, user1] }
      let(:mailer)        { double("mailer") }

      before do
        project.stub(:suppress_notifications => false)
        story.stub(:notify_users => notify_users)
        Notifications.should_receive(:new_note).with(subject, [user1]).and_return(mailer)
        mailer.should_receive(:deliver)
      end

      it "sends notifications" do
        subject.create_changeset
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
