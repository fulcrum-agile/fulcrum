require 'rails_helper'

describe StoryObserver do

  subject { StoryObserver.instance }

  let(:story) do
    mock_model(Story, title: "Test Story", acting_user: FactoryGirl.build(:user), base_uri: 'http://foo.com/projects/123', state_changed?: false, accepted_at_changed?: false)
  end

  # FIXME - Better coverage needed
  describe "#after_save" do

    context "when story state changed" do

      let(:project) { mock_model(Project, id: 1, name: "Test Project") }

      before do
        allow(project).to receive_messages(:suppress_notifications => false)
        allow(story).to receive_messages(:state_changed? => true)
        allow(story).to receive_messages(:project => project)
      end

      context "when project start date is not set" do

        before do
          allow(project).to receive_messages(:state => 'started')
        end

        it "sets the project start date" do
          expect(project).to receive(:update_attribute).with(:start_date, Date.today)
          subject.after_save(story)
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
          expect(Notifications).to receive(:started).with(story, acting_user) {
            notifier
          }
          expect(IntegrationWorker).to receive(:perform_async).with(1, "[Test Project] The story ['Test Story'](http://foo.com/projects/123#story-#{story.id}) has been started.")
          subject.after_save(story)
        end
        it "sends 'delivered' email notification" do
          allow(story).to receive_messages(:state => 'delivered')
          expect(Notifications).to receive(:delivered).with(story, acting_user) {
            notifier
          }
          expect(IntegrationWorker).to receive(:perform_async).with(1, "[Test Project] The story ['Test Story'](http://foo.com/projects/123#story-#{story.id}) has been delivered for acceptance.")
          subject.after_save(story)
        end
        it "sends 'accepted' email notification" do
          allow(story).to receive_messages(:state => 'accepted')
          expect(Notifications).to receive(:accepted).with(story, acting_user) {
            notifier
          }
          expect(IntegrationWorker).to receive(:perform_async).with(1, "[Test Project]  ACCEPTED your story ['Test Story'](http://foo.com/projects/123#story-#{story.id}).")
          subject.after_save(story)
        end
        it "sends 'rejected' email notification" do
          allow(story).to receive_messages(:state => 'rejected')
          expect(Notifications).to receive(:rejected).with(story, acting_user) {
            notifier
          }
          expect(IntegrationWorker).to receive(:perform_async).with(1, "[Test Project]  REJECTED your story ['Test Story'](http://foo.com/projects/123#story-#{story.id}).")
          subject.after_save(story)
        end
      end

    end

  end

end
