require 'rails_helper'

describe Team, type: :model do
  context "friendly_id" do
    it "should create a slug" do
      team = create(:team, name: 'Test Team')
      expect(team.slug).to eq('test-team')
    end
  end
end
