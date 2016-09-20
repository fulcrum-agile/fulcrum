require 'rails_helper'

describe Project do

  subject { build :project }

  describe "#as_json" do
    subject { create :project }

    (Project::JSON_ATTRIBUTES + Project::JSON_METHODS).each do |key|
      its(:as_json) { expect(subject.as_json['project']).to have_key(key) }
    end
  end

  describe "#last_changeset_id" do
    context "when there are no changesets" do
      before do
        allow(subject).to receive_message_chain(:changesets).and_return([])
      end

      its(:last_changeset_id) { should be_nil }
    end

    context "when there are changesets" do

      let(:changeset) { double("changeset", id: 42) }

      before do
        allow(subject).to receive(:changesets).and_return([nil, nil, changeset])
      end

      its(:last_changeset_id) { should == changeset.id }
    end
  end
end
