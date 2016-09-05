require 'rails_helper'

describe Team, type: :model do
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to have_many :enrollments }
  it { is_expected.to have_many :users }
  it { is_expected.to have_many :ownerships }
  it { is_expected.to have_many :projects }

  context "friendly_id" do
    it "should create a slug" do
      team = create(:team, name: 'Test Team')
      expect(team.slug).to eq('test-team')
    end
  end
end
