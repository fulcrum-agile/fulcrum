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

  context "#allowed_domain" do
    it "is in whitelist" do
      subject.registration_domain_whitelist = "codeminer42.com, uol.com.br"
      expect(subject.allowed_domain?("foo@codeminer42.com")).to be_truthy
      expect(subject.allowed_domain?("foo@uol.com.br")).to be_truthy
      expect(subject.allowed_domain?("foo@yahoo.com.br")).to be_falsey
    end

    it "is not in blacklist" do
      subject.registration_domain_blacklist = "hotmail.com\ngmail.com\nyahoo.com.br"
      expect(subject.allowed_domain?("foo@codeminer42.com")).to be_truthy
      expect(subject.allowed_domain?("foo@uol.com.br")).to be_truthy
      expect(subject.allowed_domain?("foo@yahoo.com.br")).to be_falsey
    end

    it "it is both in the whitelist and not in the blacklist" do
      subject.registration_domain_whitelist = "codeminer42.com, uol.com.br"
      subject.registration_domain_blacklist = "hotmail.com\ngmail.com\nyahoo.com.br"
      expect(subject.allowed_domain?("foo@codeminer42.com")).to be_truthy
      expect(subject.allowed_domain?("foo@uol.com.br")).to be_truthy
      expect(subject.allowed_domain?("foo@yahoo.com.br")).to be_falsey
      expect(subject.allowed_domain?("foo@gmail.com.br")).to be_falsey
    end
  end
end
