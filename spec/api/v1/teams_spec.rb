require 'rails_helper'

RSpec.describe V1::Teams do
  let(:api_token) { create :api_token }

  describe '#GET /api/v1/teams' do
    subject { get '/api/v1/teams', per_page: 2, api_key: api_token.token }

    before do
      create_list :team, 4
    end

    it 'returns 2 teams' do
      subject

      expect(JSON.parse(response.body).count).to eq(2)
    end

    context 'when api token is invalid' do
      let(:api_token) { double :api_token, token: 'foo' }

      it 'returns a authorization error' do
        subject

        expect(response.body).to match(/Invalid token/)
      end
    end

    context 'when api token is linked with a team' do
      let(:some_team) { create :team }
      let(:api_token) { create :api_token, team: some_team }


      it 'returns a authorization error' do
        subject

        expect(response.body).to match(/Invalid team/)
      end
    end
  end

  describe '#GET /api/v1/teams/{slug}' do
    let(:team) { create :team }

    subject { get "/api/v1/teams/#{team.slug}", per_page: 2, api_key: api_token.token }

    it 'returns the team' do
      expected = Entities::Team.new(team).as_json

      subject

      expect(JSON.parse(response.body).symbolize_keys).to eq(expected)
    end

    context 'when api token is invalid' do
      let(:api_token) { double :api_token, token: 'foo' }

      it 'returns a authorization error' do
        subject

        expect(response.body).to match(/Invalid token/)
      end
    end

    context 'when api token is linked with a team' do
      let(:some_team) { create :team }
      let(:api_token) { create :api_token, team: some_team }


      it 'returns a authorization error' do
        subject

        expect(response.body).to match(/Invalid team/)
      end
    end
  end

  describe '#GET /api/v1/teams/{slug}/projects' do
    let(:team) { create :team }
    let(:projects) { create_list :project, 4 }

    before do
      projects.each do |project|
        team.projects << project
      end

      team.save
    end

    subject do
      get "/api/v1/teams/#{team.slug}/projects", per_page: 3, api_key: api_token.token
    end

    it 'returns 3 team projects' do
      subject

      expect(JSON.parse(response.body).count).to eq(3)
    end

    context 'when api token is invalid' do
      let(:api_token) { double :api_token, token: 'foo' }

      it 'returns a authorization error' do
        subject

        expect(response.body).to match(/Invalid token/)
      end
    end

    context 'when api token is linked with a team' do
      let(:some_team) { create :team }
      let(:api_token) { create :api_token, team: some_team }


      it 'returns a authorization error' do
        subject

        expect(response.body).to match(/Invalid team/)
      end
    end
  end

  describe '#GET /api/v1/teams/{slug}/users' do
    let(:team) { create :team }
    let(:users) { create_list :user, 4 }

    before do
      users.each do |user|
        team.users << user
      end

      team.save
    end

    subject { get "/api/v1/teams/#{team.slug}/users", per_page: 2, api_key: api_token.token }

    it 'returns 2 team users' do
      subject

      expect(JSON.parse(response.body).count).to eq(2)
    end

    context 'when api token is invalid' do
      let(:api_token) { double :api_token, token: 'foo' }

      it 'returns a authorization error' do
        subject

        expect(response.body).to match(/Invalid token/)
      end
    end

    context 'when api token is linked with a team' do
      let(:some_team) { create :team }
      let(:api_token) { create :api_token, team: some_team }


      it 'returns a authorization error' do
        subject

        expect(response.body).to match(/Invalid team/)
      end
    end
  end
end
