require 'rails_helper'

describe Changeset do

  describe "validations" do

    it "must have a story" do
      subject.story = nil
      subject.valid?
      expect(subject.errors[:story].size).to eq(1)
    end

    describe "associations" do
      let(:user)    { create(:user) }
      let(:project) { create(:project, users: [user]) }
      let(:story)   { create(:story, project: project,
                                     requested_by: user) }
      let(:changeset) { create :changeset, story: story, project: project }

      it "must have a valid project" do
        changeset.project_id = "invalid"
        changeset.valid?
        expect(changeset.errors[:project].size).to eq(1)
      end

      it "must have a valid story" do
        changeset.story_id = "invalid"
        changeset.valid?
        expect(changeset.errors[:story].size).to eq(1)
      end
    end
  end

  describe "#project_id" do

    context "when project_id is blank" do

      let(:user)    { create(:user) }
      let(:project) { create(:project, users: [user]) }
      let(:story)   { create(:story, project: project,
                                     requested_by: user) }

      subject do
        create :changeset, story: story, project: nil
      end

      it "shouldn't have any errors on project" do
        story.valid?
        expect(story.errors[:project].size).to eq(0)
      end

      its(:project) { should == project }

    end

  end

  describe ".since" do
    specify do
      expect(Changeset.since(234).where_values.first).to eq('id > 234')
    end
  end
end
