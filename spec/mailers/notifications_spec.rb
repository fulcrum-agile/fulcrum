require 'rails_helper'

describe Notifications do
  let(:requested_by) { mock_model(User, email: 'requested_by@email.com') }
  let(:owned_by) { mock_model(User, name: 'Developer', email: 'owned_by@email.com') }
  let(:project) { mock_model(Project, name: 'Test Project') }
  let(:story) do
    mock_model(
      Story, title: 'Test story', requested_by: requested_by,
      owned_by: owned_by, project: project,
      story_type: 'feature'
    )
  end

  before do
    allow(User).to receive(:find).and_return(owned_by)
    allow(Story).to receive(:find).and_return(story)
  end

  describe "#started with story without estimation" do
    subject { Notifications.started(story, owned_by) }

    its(:subject) { should match "[Test Project] Your story 'Test story' has been started."}
    its(:to)      { should match [requested_by.email] }
    its(:from)    { should match [owned_by.email] }

    specify { expect(subject.body.encoded).to match("Developer has started your story 'Test story'.") }
    specify { expect(subject.body.encoded).to match("This story is NOT estimated. Ask Developer to add proper estimation before implementation!") }
    specify { expect(subject.body.encoded).to match(project_url(project)) }
  end

  describe "#started with story with estimation" do
    before do
      allow(story).to receive_messages(estimate: 10)
    end

    subject { Notifications.started(story, owned_by) }

    its(:subject) { should match "[Test Project] Your story 'Test story' has been started."}
    its(:to)      { should match [requested_by.email] }
    its(:from)    { should match [owned_by.email] }

    specify { expect(subject.body.encoded).to match("Developer has started your story 'Test story'.") }
    specify { expect(subject.body.encoded).to match("The estimation of this story is 10 points.") }
    specify { expect(subject.body.encoded).to match(project_url(project)) }
  end

  describe "#started with story with estimation" do
    before do
      allow(story).to receive_messages(story_type: 'bug')
    end

    subject { Notifications.started(story, owned_by) }

    its(:subject) { should match "[Test Project] Your story 'Test story' has been started."}
    its(:to)      { should match [requested_by.email] }
    its(:from)    { should match [owned_by.email] }

    specify { expect(subject.body.encoded).to match("Developer has started your story 'Test story'.") }
    specify { expect(subject.body.encoded).to match("This is either a bug or a chore There is no estimation. Expect the sprint velocity to decrease.") }
    specify { expect(subject.body.encoded).to match(project_url(project)) }
  end

  describe "#delivered" do
    let(:delivered_by) { mock_model(User, name: 'Deliverer', email: 'delivered_by@email.com') }

    before do
      allow(User).to receive(:find).and_return(delivered_by)
    end

    subject  { Notifications.delivered(story, delivered_by) }

    its(:subject) { should match "[Test Project] Your story 'Test story' has been delivered for acceptance." }
    its(:to)      { should match [requested_by.email] }
    its(:from)    { should match [delivered_by.email] }

    specify { expect(subject.body.encoded).to match("Deliverer has delivered your story 'Test story'.") }
    specify { expect(subject.body.encoded).to match("You can now review the story, and either accept or reject it.") }
    specify { expect(subject.body.encoded).to match(project_url(project)) }

  end

  describe "#accepted" do
    let(:accepted_by) { mock_model(User, name: 'Accepter', email: 'accerpter@email.com') }

    subject { Notifications.accepted(story, accepted_by) }
    before { allow(User).to receive_messages(find: accepted_by) }

    its(:subject) { should match "[Test Project] Accepter ACCEPTED your story 'Test story'." }
    its(:to)      { should match [owned_by.email] }
    its(:from)    { should match [accepted_by.email] }

    specify { expect(subject.body.encoded).to match("Accepter has accepted the story 'Test story'.") }
    specify { expect(subject.body.encoded).to match(project_url(project)) }

  end

  describe "#rejected" do
    let(:rejected_by) { mock_model(User, name: 'Rejecter', email: 'rejecter@email.com') }

    subject { Notifications.rejected(story, rejected_by) }
    before { allow(User).to receive_messages(find: rejected_by) }

    its(:subject) { should match "[Test Project] Rejecter REJECTED your story 'Test story'." }
    its(:to)      { should match [owned_by.email] }
    its(:from)    { should match [rejected_by.email] }

    specify { expect(subject.body.encoded).to match("Rejecter has rejected the story 'Test story'.") }
    specify { expect(subject.body.encoded).to match(project_url(project)) }
  end

  describe "#new_note" do

    let(:notify_users)  { [mock_model(User, email: 'foo@example.com')] }
    let(:user)          { mock_model(User, name: 'Note User') }
    let(:note)          { mock_model(Note, story: story, user: user) }

    subject { Notifications.new_note(note.id, notify_users.map(&:email)) }
    before { allow(Note).to receive_message_chain(:includes, :find).and_return(note) }

    its(:subject) { should == "[Test Project] New comment on 'Test story'" }
    its(:to)      { ['foo@example.com'] }
    its(:from)    { [user.email] }

    specify { expect(subject.body.encoded).to match("Note User added the following comment to the story") }
  end
end
