require 'spec_helper'

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
      story.changesets.should_receive(:create!)
    end
    
    context "when story state changed" do

      let(:project) { mock_model(Project) }

      before do
        project.stub(:suppress_notifications => false)
        story.unstub(:state_changed?)
        story.stub(:state_changed? => true)
        story.stub(:project => project)
      end

      context "when project start date is not set" do

        before do
          project.stub(:state => 'started')
        end

        it "sets the project start date" do
          project.should_receive(:update_attribute).with(:start_date, Date.today)
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
          story.stub(:acting_user => acting_user)
          story.stub(:requested_by => requested_by)
          story.stub(:owned_by => owned_by)
          project.stub(:start_date => true)
          notifier.should_receive(:deliver)
        end

        it "sends 'delivered' email notification" do
          story.stub(:state => 'delivered')
          Notifications.should_receive(:delivered).with(story, acting_user) {
            notifier
          }
          subject.after_save(story)
        end
        it "sends 'accepted' email notification" do
          story.stub(:state => 'accepted')
          Notifications.should_receive(:accepted).with(story, acting_user) {
            notifier
          }
          subject.after_save(story)
        end
        it "sends 'rejected' email notification" do
          story.stub(:state => 'rejected')
          Notifications.should_receive(:rejected).with(story, acting_user) {
            notifier
          }
          subject.after_save(story)
        end
      end

    end

  end

end
