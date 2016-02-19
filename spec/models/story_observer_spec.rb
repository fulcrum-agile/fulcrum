require 'rails_helper'

describe StoryObserver do

  subject { StoryObserver.instance }

  let(:story) do
    mock_model(Story, :changesets     => double("changesets"),
               :state_changed?        => false,
               :accepted_at_changed?  => false)
  end

  # FIXME - Better coverage needed
  describe "#after_save" do

    before do
      # Should always create a changeset
      expect(story.changesets).to receive(:create!)
    end
    
    context "when story state changed" do

      let(:project) { mock_model(Project) }

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
        let(:notifier)      { double("notifier") }

        before do
          allow(story).to receive_messages(:acting_user => acting_user)
          allow(story).to receive_messages(:requested_by => requested_by)
          allow(story).to receive_messages(:owned_by => owned_by)
          allow(project).to receive_messages(:start_date => true)
          expect(notifier).to receive(:deliver)
        end

        it "sends 'delivered' email notification" do
          allow(story).to receive_messages(:state => 'delivered')
          expect(Notifications).to receive(:delivered).with(story, acting_user) {
            notifier
          }
          subject.after_save(story)
        end
        it "sends 'accepted' email notification" do
          allow(story).to receive_messages(:state => 'accepted')
          expect(Notifications).to receive(:accepted).with(story, acting_user) {
            notifier
          }
          subject.after_save(story)
        end
        it "sends 'rejected' email notification" do
          allow(story).to receive_messages(:state => 'rejected')
          expect(Notifications).to receive(:rejected).with(story, acting_user) {
            notifier
          }
          subject.after_save(story)
        end
      end

    end

  end

end
