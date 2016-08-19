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
end
