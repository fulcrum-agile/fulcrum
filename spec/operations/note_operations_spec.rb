require 'rails_helper'

describe NoteOperations do
  describe '::Create' do
    let!(:membership)     { create(:membership) }
    let(:user)            { User.first }
    let(:project)         { Project.first }
    let(:story)           { create(:story, project: project, requested_by: user) }

    let(:note) { story.notes.build(note: 'name', user: build(:user)) }

    context 'with valid params' do

      subject { ->{NoteOperations::Create.run(note, user)} }

      it { expect { subject.call }.to change(Note, :count) }
      it { expect { subject.call }.to change(Changeset, :count) }
      it { expect(subject.call).to be_eql Note.last }

      context 'when suppress_notifications is off' do
        before { note.save }

        let(:mailer) { double('mailer') }

        it 'sends notifications' do
          expect(Notifications).to receive(:new_note).with(note.id, [user.email]).and_return(mailer)
          expect(mailer).to receive(:deliver)

          subject.call
        end

        context 'when note message has a valid username' do
          it 'also sends notification for the found username' do
            username_user = project.users.create(
              build(:unconfirmed_user, username: 'username').attributes
            )
            note.note = 'name @username'
            note.user = build(:user)

            expect(Notifications).to receive(:new_note).
              with(note.id, [user.email, username_user.email]).and_return(mailer)
            expect(mailer).to receive(:deliver)

            subject.call
          end
        end
      end
    end

    context 'with invalid params' do
      before { note.note = '' }

      subject { ->{NoteOperations::Create.run(note, user)} }

      it { expect { subject.call }.to_not change(Note, :count) }
      it { expect(subject.call).to be_falsy }
      it { expect(Notifications).to_not receive(:new_note) }
    end
  end
end
