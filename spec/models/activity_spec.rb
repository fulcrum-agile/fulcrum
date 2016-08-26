require 'rails_helper'

describe Activity, type: :model do
  context 'invalid params' do
    it 'must raise validation errors' do
      activity = Activity.new
      activity.valid?
      expect(activity.errors[:project].size).to eq(1)
      expect(activity.errors[:user].size).to eq(1)
      expect(activity.errors[:subject].size).to eq(1)
      expect(activity.errors[:action].size).to eq(2)
    end
  end

  context 'valid params' do
    let(:story) { create(:story, :with_project) }
    let(:activity) { build(:activity, action: 'update', subject: story ) }

    context 'nothing changed' do
      it 'is invalid' do
        activity.valid?
        expect(activity.errors[:subject].count).to be(1)
      end
    end

    it "should save without parsing changes" do
      activity.action = 'create'
      expect(activity.save).to be_truthy
    end

    it "should fetch the changes from the model" do
      story.title = 'new story title'
      story.estimate = 4
      story.position = 1.5
      story.state = 'finished'

      activity.save

      expect(activity.subject_changes).to eq({
        "title"=>["Test story", "new story title"],
        "estimate"=>[nil, 4],
        "position"=>[1.0, 1.5],
        "state"=>["unstarted", "finished"]})
    end
  end
end
