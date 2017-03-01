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

  describe '#story_changed with invalid state' do
    before { allow(story).to receive_messages(state: :invalid_state) }
    subject { Notifications.story_changed(story, double).__getobj__ }

    it { is_expected.to be_a ActionMailer::Base::NullMail }
  end

  describe "#story_changed to started" do
    before { allow(story).to receive_messages(state: :started) }
    subject { Notifications.story_changed(story, owned_by) }

    its(:subject) { should match "[Test Project] Your story 'Test story' has been started."}
    its(:to)      { should match [requested_by.email] }
    its(:from)    { should match [owned_by.email] }
    its(:body)    { should match project_url(project) }
    its(:body)    { should match "Developer has started your story 'Test story'." }

    context "with story without estimation" do
      its(:body) { should match "This story is NOT estimated. Ask Developer to add proper estimation before implementation!" }
    end

    context "with story with estimation" do
      before { allow(story).to receive_messages(estimate: 10) }

      its(:body) { should match "The estimation of this story is 10 points." }
    end

    context "with a bug story" do
      before { allow(story).to receive_messages(story_type: 'bug') }

      its(:body) { should match "This is either a bug or a chore There is no estimation. Expect the sprint velocity to decrease." }
    end
  end

  describe "#story_changed to delivered" do
    let(:delivered_by) { mock_model(User, name: 'Deliverer', email: 'delivered_by@email.com') }
    before { allow(story).to receive_messages(state: :delivered) }
    subject  { Notifications.story_changed(story, delivered_by) }

    its(:subject) { should match "[Test Project] Your story 'Test story' has been delivered for acceptance." }
    its(:to)      { should match [requested_by.email] }
    its(:from)    { should match [delivered_by.email] }
    its(:body)    { should match "Deliverer has delivered your story 'Test story'." }
    its(:body)    { should match "You can now review the story, and either accept or reject it." }
    its(:body)    { should match project_url(project) }
  end

  describe "#story_changed to accepted" do
    let(:accepted_by) { mock_model(User, name: 'Accepter', email: 'accerpter@email.com') }

    before { allow(story).to receive_messages(state: :accepted) }
    subject { Notifications.story_changed(story, accepted_by) }

    its(:subject) { should match "[Test Project] Accepter ACCEPTED your story 'Test story'." }
    its(:to)      { should match [owned_by.email] }
    its(:from)    { should match [accepted_by.email] }
    its(:body)    { should match "Accepter has accepted the story 'Test story'." }
    its(:body)    { should match project_url(project) }
  end

  describe "#story_changed to rejected" do
    let(:rejected_by) { mock_model(User, name: 'Rejecter', email: 'rejecter@email.com') }

    before { allow(story).to receive_messages(state: :rejected) }
    subject { Notifications.story_changed(story, rejected_by) }

    its(:subject) { should match "[Test Project] Rejecter REJECTED your story 'Test story'." }
    its(:to)      { should match [owned_by.email] }
    its(:from)    { should match [rejected_by.email] }
    its(:body)    { should match "Rejecter has rejected the story 'Test story'." }
    its(:body)    { should match project_url(project) }
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
