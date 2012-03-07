require 'spec_helper'

describe StoryObserver do

  subject { StoryObserver.instance }

  let(:story) do
    mock_model(Story, :changesets     => mock("changesets"),
               :state_changed?        => false,
               :accepted_at_changed?  => false)
  end

  # FIXME - Better coverage needed
  describe "#after_save" do
    
    it "creates a changeset" do
      story.changesets.should_receive(:create!)
      subject.after_save(story)
    end

    pending "sends 'delivered' email notification"
    pending "sends 'accepted' email notification"
    pending "sends 'rejected' email notification"
    pending "sets project started_date"

  end

end
