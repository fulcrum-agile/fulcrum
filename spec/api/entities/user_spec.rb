require 'rails_helper'

RSpec.describe Entities::User do
  let(:user) do
    create :user,
           current_sign_in_at: nil,
           confirmed_at: nil,
           last_sign_in_at: nil
  end

  subject { described_class.represent(user).as_json }

  it { expect(subject[:initials]).to eq(user.initials) }
  it { expect(subject[:name]).to eq(user.name) }
  it { expect(subject[:email]).to eq(user.email) }
  it { expect(subject[:sign_in_count]).to eq(user.sign_in_count) }
  it { expect(subject[:confirmed_at]).to eq(user.confirmed_at.iso8601) }
  it { expect(subject[:last_sign_in_at]).to be_nil }
  it { expect(subject[:current_sign_in_at]).to be_nil }

  context 'when current signed in' do
    let(:user) { create :user, current_sign_in_at: 1.day.ago }

    it { expect(subject[:current_sign_in_at]).to eq(user.current_sign_in_at.iso8601) }
  end

  context 'when last signed in' do
    let(:user) { create :user, last_sign_in_at: 1.day.ago }

    it { expect(subject[:last_sign_in_at]).to eq(user.last_sign_in_at.iso8601) }
  end
end
