require 'rails_helper'

RSpec.describe V1::Users do
  let(:api_token) { create :api_token }

  describe '#GET /api/v1/users' do
    context 'when api token is invalid' do
      let(:api_token) { double :api_token, token: 'foo' }

      subject { get '/api/v1/users', api_key: api_token.token }
      it 'returns a authorization error' do
        subject

        expect(response.body).to match(/Invalid token/)
      end
    end

    context 'when fetch user' do
      subject { get '/api/v1/users', per_page: 2, api_key: api_token.token }

      before do
        create_list :user, 4
      end

      it 'returns 2 users' do
        subject
        expect(JSON.parse(response.body).count).to eq(2)
      end
    end

    context 'when fetch only new users' do
      subject { get '/api/v1/users', created_at: 1.day.ago, api_key: api_token.token }

      before do
        create_list :user, 3, created_at: 3.days.ago
        create_list :user, 2, created_at: 1.hour.ago
      end

      it 'returns 2 users' do
        subject
        expect(JSON.parse(response.body).count).to eq(2)
      end
    end
  end
end
