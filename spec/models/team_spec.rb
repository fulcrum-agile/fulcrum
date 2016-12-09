require 'rails_helper'

describe Team, type: :model do
  it { is_expected.to have_many(:api_tokens) }

  context "friendly_id" do
    it "should create a slug" do
      team = create(:team, name: 'Test Team')
      expect(team.slug).to eq('test-team')
    end
  end
end
