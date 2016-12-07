require 'rails_helper'

RSpec.describe V1::Health do
  describe '#GET check' do

    it 'returns ok' do
      get '/api/v1/health'

      expect(response.body).to eq({ status: 'ok' }.to_json)
    end
  end
end
