require 'rails_helper'

RSpec.describe V1::Health do
  describe '#GET check' do
    subject { get '/api/v1/health' }

    it 'returns ok' do
      subject
      expect(response.body).to eq({ status: 'ok' }.to_json)
    end
  end
end
