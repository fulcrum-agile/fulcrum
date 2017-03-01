require 'rails_helper'

RSpec.describe Entities::Story do
  let(:story) do
    create :story, :with_project, started_at: nil, accepted_at: nil
  end

  subject { described_class.represent(story).as_json }

  it { expect(subject[:id]).to eq(story.id) }
  it { expect(subject[:title]).to eq(story.title) }
  it { expect(subject[:description]).to eq(story.description) }
  it { expect(subject[:story_type]).to eq(story.story_type) }
  it { expect(subject[:estimate]).to eq(story.estimate) }
  it { expect(subject[:state]).to eq(story.state) }
  it { expect(subject[:labels]).to eq(story.labels) }
  it { expect(subject[:requested_by_name]).to eq(story.requested_by_name) }
  it { expect(subject[:cycle_time]).to eq(story.cycle_time) }
  it { expect(subject[:owned_by_name]).to eq(story.owned_by_name) }
  it { expect(subject[:owned_by_initials]).to eq(story.owned_by_initials) }
  it { expect(subject[:created_at]).to eq(story.created_at.iso8601) }

  context 'when started at' do
    let(:story) { create :story, :with_project, started_at: 1.day.ago }

    it { expect(subject[:started_at]).to eq(story.started_at.iso8601) }
  end

  context 'when accepted at' do
    let(:story) { create :story, :with_project, accepted_at: 1.day.ago }

    it { expect(subject[:accepted_at]).to eq(story.accepted_at.iso8601) }
  end
end
