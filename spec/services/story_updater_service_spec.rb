require 'rails_helper'

describe StoryUpdaterService do
  describe '#save' do
    let!(:membership)     { create(:membership) }
    let(:user)            { User.first }
    let(:project)         { Project.first }
    let(:story_params)    { { title: 'Foo bar', requested_by: user } }
    let(:story)           { project.stories.new }

    context 'with valid params' do
      subject { ->{StoryUpdaterService.save(story, story_params)} }

      it { is_expected.to change {Story.count} }
      it { is_expected.to change {Changeset.count} }
      it { expect(subject.call).to be_eql Story.last }

      context 'when note message has a valid username' do
        let(:mailer) { double('mailer') }

        it 'also sends notification for the found username' do
          username_user = project.users.create(
            build(:unconfirmed_user, username: 'username').attributes
          )
          story = project.stories.create(
            story_params.merge(description: 'Foo @username')
          )

          expect(Notifications).to receive(:story_mention).
            with(story, [username_user]).and_return(mailer)
          expect(mailer).to receive(:deliver)

          StoryUpdaterService.save(story)
        end
      end
    end

    context 'with invalid params' do
      subject { ->{StoryUpdaterService.save(story, title: '')} }

      it { is_expected.to_not change {Story.count} }
      it { expect(subject.call).to be_falsy }
      it { expect(Notifications).to_not receive(:story_mention) }
    end
  end

  describe 'moved from old story observer' do
    let(:story) do
      mock_model(Story, title: "Test Story", acting_user: FactoryGirl.build(:user), base_uri: 'http://foo.com/projects/123', state_changed?: false, accepted_at_changed?: false)
    end

    context "when story state changed" do

      let(:project) { mock_model(Project, id: 1, name: "Test Project") }

      before do
        allow(story).to receive_messages(:suppress_notifications => false)
        allow(story).to receive_messages(:state_changed? => true)
        allow(story).to receive_messages(:project => project)
        allow(story).to receive_messages(:save! => story)
        allow(story).to receive_message_chain(:changesets, :create!)
      end

      context "when project start date is not set" do

        before do
          allow(project).to receive_messages(:state => 'started')
        end

        it "sets the project start date" do
          expect(project).to receive(:update_attribute).with(:start_date, Date.today)
          StoryUpdaterService.save(story, {})
        end

      end

      describe "notifications" do

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
          expect(notifier).to receive(:deliver)
        end

        it "sends 'started' email notification" do
          allow(story).to receive_messages(:state => 'started')
          expect(Notifications).to receive(:public_send).with(:started, story, acting_user) {
            notifier
          }
          expect(IntegrationWorker).to receive(:perform_async).with(1, "[Test Project] The story ['Test Story'](http://foo.com/projects/123#story-#{story.id}) has been started.")
          StoryUpdaterService.save(story, {})
        end
        it "sends 'delivered' email notification" do
          allow(story).to receive_messages(:state => 'delivered')
          expect(Notifications).to receive(:public_send).with(:delivered, story, acting_user) {
            notifier
          }
          expect(IntegrationWorker).to receive(:perform_async).with(1, "[Test Project] The story ['Test Story'](http://foo.com/projects/123#story-#{story.id}) has been delivered for acceptance.")
          StoryUpdaterService.save(story, {})
        end
        it "sends 'accepted' email notification" do
          allow(story).to receive_messages(:state => 'accepted')
          expect(Notifications).to receive(:public_send).with(:accepted, story, acting_user) {
            notifier
          }
          expect(IntegrationWorker).to receive(:perform_async).with(1, "[Test Project]  ACCEPTED your story ['Test Story'](http://foo.com/projects/123#story-#{story.id}).")
          StoryUpdaterService.save(story, {})
        end
        it "sends 'rejected' email notification" do
          allow(story).to receive_messages(:state => 'rejected')
          expect(Notifications).to receive(:public_send).with(:rejected, story, acting_user) {
            notifier
          }
          expect(IntegrationWorker).to receive(:perform_async).with(1, "[Test Project]  REJECTED your story ['Test Story'](http://foo.com/projects/123#story-#{story.id}).")
          StoryUpdaterService.save(story, {})
        end
      end

    end
  end
end
