require 'rails_helper'

describe NoteCreationService do
  describe '#create' do
    let!(:membership)     { create(:membership) }
    let(:user)            { User.first }
    let(:project)         { Project.first }
    let(:story)           { create(:story, project: project, requested_by: user) }

    context 'with valid params' do
      subject { ->{NoteCreationService.create(story.notes.build(note: 'name'))} }

      it { is_expected.to change {Note.count} }
      it { is_expected.to change {Changeset.count} }
      it { expect(subject.call).to be_eql Note.last }

      context 'when suppress_notifications is off' do
        let(:mailer) { double('mailer') }

        it 'sends notifications' do
          note = story.notes.build(note: 'name', user: build(:user))

          expect(Notifications).to receive(:new_note).with(note, [user]).and_return(mailer)
          expect(mailer).to receive(:deliver)

          NoteCreationService.create(note)
        end
      end
    end

    context 'with invalid params' do
      subject { ->{NoteCreationService.create(story.notes.build(note: ''))} }

      it { is_expected.to_not change {Note.count} }
      it { expect(subject.call).to be_falsy }
      it { expect(Notifications).to_not receive(:new_note) }
    end
  end
end
