require 'rails_helper'

describe Notifications do

  let(:requested_by) { mock_model(User) }
  let(:owned_by) { mock_model(User) }
  let(:project) { mock_model(Project, name: 'Test Project') }
  let(:story) do
    mock_model(
      Story, title: 'Test story', requested_by: requested_by,
      owned_by: owned_by, project: project,
      story_type: 'feature'
    )
  end

  describe "#started with story without estimation" do
    let(:owned_by) { mock_model(User, name: 'Developer') }

    subject { Notifications.started(story, owned_by) }

    its(:subject) { should == "[Test Project] Your story 'Test story' has been started."}
    its(:to)      { [requested_by.email] }
    its(:from)    { [owned_by.email] }

    specify { expect(subject.body.encoded).to match("Developer has started your story 'Test story'.") }
    specify { expect(subject.body.encoded).to match("This story is NOT estimated. Ask Developer to add proper estimation before implementation!") }
    specify { expect(subject.body.encoded).to match(project_url(project)) }
  end

  describe "#started with story with estimation" do
    let(:estimated_story) do
      mock_model(
        Story, title: 'Test story', requested_by: requested_by,
        owned_by: owned_by, project: project, project_name: project.name,
        story_type: 'feature', estimate: 10
      )
    end

    let(:owned_by) { mock_model(User, name: 'Developer') }

    subject { Notifications.started(estimated_story, owned_by) }

    its(:subject) { should == "[Test Project] Your story 'Test story' has been started."}
    its(:to)      { [requested_by.email] }
    its(:from)    { [owned_by.email] }

    specify { expect(subject.body.encoded).to match("Developer has started your story 'Test story'.") }
    specify { expect(subject.body.encoded).to match("The estimation of this story is 10 points.") }
    specify { expect(subject.body.encoded).to match(project_url(project)) }
  end

  describe "#started with story with estimation" do
    let(:bug_story) do
      mock_model(
        Story, title: 'Test story', requested_by: requested_by,
        owned_by: owned_by, project: project, project_name: project.name,
        story_type: 'bug', estimate: 0
      )
    end

    let(:owned_by) { mock_model(User, name: 'Developer') }

    subject { Notifications.started(bug_story, owned_by) }

    its(:subject) { should == "[Test Project] Your story 'Test story' has been started."}
    its(:to)      { [requested_by.email] }
    its(:from)    { [owned_by.email] }

    specify { expect(subject.body.encoded).to match("Developer has started your story 'Test story'.") }
    specify { expect(subject.body.encoded).to match("This is either a bug or a chore There is no estimation. Expect the sprint velocity to decrease.") }
    specify { expect(subject.body.encoded).to match(project_url(project)) }
  end

  describe "#delivered" do

    let(:delivered_by) { mock_model(User, name: 'Deliverer') }

    subject  { Notifications.delivered(story, delivered_by) }

    its(:subject) { should == "[Test Project] Your story 'Test story' has been delivered for acceptance." }
    its(:to)      { [requested_by.email] }
    its(:from)    { [delivered_by.email] }

    specify { expect(subject.body.encoded).to match("Deliverer has delivered your story 'Test story'.") }
    specify { expect(subject.body.encoded).to match("You can now review the story, and either accept or reject it.") }
    specify { expect(subject.body.encoded).to match(project_url(project)) }

  end

  describe "#accepted" do

    let(:accepted_by) { mock_model(User, name: 'Accepter') }

    subject  { Notifications.accepted(story, accepted_by) }

    its(:subject) { should == "[Test Project] Accepter ACCEPTED your story 'Test story'." }
    its(:to)      { [owned_by.email] }
    its(:from)    { [accepted_by.email] }

    specify { expect(subject.body.encoded).to match("Accepter has accepted the story 'Test story'.") }
    specify { expect(subject.body.encoded).to match(project_url(project)) }

  end

  describe "#rejected" do

    let(:rejected_by) { mock_model(User, name: 'Rejecter') }

    subject  { Notifications.rejected(story, rejected_by) }

    its(:subject) { should == "[Test Project] Rejecter REJECTED your story 'Test story'." }
    its(:to)      { [owned_by.email] }
    its(:from)    { [rejected_by.email] }

    specify { expect(subject.body.encoded).to match("Rejecter has rejected the story 'Test story'.") }
    specify { expect(subject.body.encoded).to match(project_url(project)) }

  end

  describe "#new_note" do

    let(:notify_users)  { [mock_model(User, email: 'foo@example.com')] }
    let(:user)          { mock_model(User, name: 'Note User') }
    let(:note)          { mock_model(Note, story: story, user: user) }

    subject { Notifications.new_note(note.id, notify_users) }
    before { allow(Note).to receive_message_chain(:includes, :find).and_return(note) }

    its(:subject) { should == "[Test Project] New comment on 'Test story'" }
    its(:to)      { ['foo@example.com'] }
    its(:from)    { [user.email] }

    specify { expect(subject.body.encoded).to match("Note User added the following comment to the story") }
  end
end
