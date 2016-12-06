require 'rails_helper'

RSpec.describe Entities::Team do
  let(:team) { create :team, archived_at: nil }

  subject { described_class.represent(team).as_json }

  it { expect(subject[:slug]).to eq(team.slug) }
  it { expect(subject[:name]).to eq(team.name) }
  it { expect(subject[:logo]).to eq(team.logo) }
  it { expect(subject[:disable_registration]).to eq(team.disable_registration) }
  it { expect(subject[:archived_at]).to be_nil }

  context 'when archived' do
    let(:team) { create :team, archived_at: 1.day.ago }

    it { expect(subject[:archived_at]).to eq(team.archived_at.iso8601) }
  end
end
