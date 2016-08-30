require 'rails_helper'

describe StoryOperations do
  let!(:membership)     { create(:membership) }
  let(:user)            { User.first }
  let(:project)         { Project.first }
  let(:story_params)    { { title: 'Test Story', requested_by: user, state: 'unstarted', accepted_at: nil } }
  let(:story)           { project.stories.build(story_params) }

  describe '::Create' do

    subject { ->{StoryOperations::Create.(story, user)} }

    context 'with valid params' do
      it { expect { subject.call }.to change {Story.count} }
      it { expect { subject.call }.to change {Changeset.count} }
      it { expect(subject.call).to be_eql Story.last }
    end

    context 'with invalid params' do
      before { story.title = '' }

      it { is_expected.to_not change {Story.count} }
      it { expect(subject.call).to be_falsy }
      it { expect(Notifications).to_not receive(:story_mention) }
    end

    context '::MemberNotification' do
      let(:mailer) { double('mailer') }
      let(:username_user) { project.users.create(
          build(:unconfirmed_user, username: 'username').attributes
        )}
      let(:story) { project.stories.create(
          story_params.merge(description: 'Foo @username')
        )}

      it 'also sends notification for the found username' do
        expect(Notifications).to receive(:story_mention).
          with(story, [username_user]).and_return(mailer)
        expect(mailer).to receive(:deliver)

        subject.call
      end
    end
  end

  describe "#documents_attributes", focus: true do
    before do
      story.save!
    end

    subject { ->{StoryOperations::Update.(story, { documents: new_documents }, user) } }

    let(:attachments) { [
      {"id"=>30, "public_id"=>"hello.jpg", "version"=>"1471624237", "format"=>"png", "resource_type"=>"image"},
      {"id"=>31, "public_id"=>"hello2.jpg", "version"=>"1471624237", "format"=>"png", "resource_type"=>"image"}
    ]}

    let(:new_documents) { [
      {"public_id"=>"hello3.jpg", "version"=>"1471624237", "format"=>"png", "resource_type"=>"image"},
      {"id"=>31, "public_id"=>"hello2.jpg", "version"=>"1471624237", "format"=>"png", "resource_type"=>"image"}
    ]}

    before do
      attachments.each do |a|
        Story.connection.execute("insert into attachinary_files (#{a.keys.join(", ")}, scope, attachinariable_id, attachinariable_type) values ('#{a.values.join("', '")}', 'documents', #{story.id}, 'Story')")
      end
    end

    it 'must record the documents attributes changes' do
      VCR.use_cassette("cloudinary_upload_activity") do
        subject.call
      end
      expect(Activity.last.subject_changes['documents_attributes']).to eq([["hello2.jpg", "hello.jpg"], ["hello2.jpg", "hello3.jpg"]])
    end
  end

  describe '::Update' do
    before do
      story.save!
    end

    subject { ->{StoryOperations::Update.(story, { state: 'accepted', accepted_at: Date.today }, user) } }

    context "::LegacyFixes" do

      it "sets the project start date if it doesn't exist" do
        story.project.update_attribute(:start_date, nil)
        expect(subject.call.project.start_date).to_not be_nil
      end

      it "sets the project start date if it's newer than the accepted story" do
        story.project.update_attribute(:start_date, Date.today + 2.days)
        expect(subject.call.project.start_date).to eq(story.accepted_at)
      end

    end

    context "::StateChangeNotification" do

      let(:acting_user)   { mock_model(User) }
      let(:requested_by)  { mock_model(User, :email_delivery? => true) }
      let(:owned_by)      { mock_model(User, :email_acceptance? => true,
                                             :email_rejection? => true) }
      let(:notifier)      { double("notifier", subject: "hello") }

      before do
        allow(story).to receive_messages(:acting_user => acting_user)
        allow(story).to receive_messages(:requested_by => requested_by)
        allow(story).to receive_messages(:owned_by => owned_by)
        allow(project).to receive_messages(:start_date => true)
        allow(project).to receive_message_chain(:integrations, :count).and_return(1)
        allow(story).to receive_messages(:base_uri => 'http://foo.com/projects/123')
        expect(notifier).to receive(:deliver)
      end

      it "sends 'started' email notification" do
        allow(story).to receive_messages(:state => 'started')
        expect(Notifications).to receive(:public_send).with(:started, story, acting_user) {
          notifier
        }
        expect(IntegrationWorker).to receive(:perform_async).with(project.id, "[Test Project] The story ['Test Story'](http://foo.com/projects/123#story-#{story.id}) has been started.")
        subject.call
      end
      it "sends 'delivered' email notification" do
        allow(story).to receive_messages(:state => 'delivered')
        expect(Notifications).to receive(:public_send).with(:delivered, story, acting_user) {
          notifier
        }
        expect(IntegrationWorker).to receive(:perform_async).with(project.id, "[Test Project] The story ['Test Story'](http://foo.com/projects/123#story-#{story.id}) has been delivered for acceptance.")
        subject.call
      end
      it "sends 'accepted' email notification" do
        allow(story).to receive_messages(:state => 'accepted')
        expect(Notifications).to receive(:public_send).with(:accepted, story, acting_user) {
          notifier
        }
        expect(IntegrationWorker).to receive(:perform_async).with(project.id, "[Test Project]  ACCEPTED your story ['Test Story'](http://foo.com/projects/123#story-#{story.id}).")
        subject.call
      end
      it "sends 'rejected' email notification" do
        allow(story).to receive_messages(:state => 'rejected')
        expect(Notifications).to receive(:public_send).with(:rejected, story, acting_user) {
          notifier
        }
        expect(IntegrationWorker).to receive(:perform_async).with(project.id, "[Test Project]  REJECTED your story ['Test Story'](http://foo.com/projects/123#story-#{story.id}).")
        subject.call
      end
    end

  end
end

