require 'rails_helper'

RSpec.describe V1::Projects do
  let(:api_token) { create :api_token }

  before do
    Timecop.freeze(Date.new(2016, 12, 7))
  end

  after do
    Timecop.return
  end

  describe '#GET /api/v1/projects' do
    let(:team) { create :team }

    before(:each) do
      create_list :project, 4, teams: [team]
      get '/api/v1/projects', per_page: 2, api_key: api_token.token
    end

    it 'returns 2 projects' do
      expect(JSON.parse(response.body).count).to eq(2)
    end

    context 'when api token is invalid' do
      let(:api_token) { double :api_token, token: 'foo' }

      it 'returns a authorization error' do
        expect(response.body).to match(/Invalid token/)
      end
    end

    context 'when api token is linked with a team' do
      let(:some_team) { create :team }
      let(:api_token) { create :api_token, team: some_team }

      it 'returns a authorization error' do
        expect(response.body).to match('[]')
      end
    end
  end

  describe '#GET /api/v1/projects/{slug}' do
    let(:project) { create :project }

    before(:each) do
      get "/api/v1/projects/#{project.slug}", per_page: 2, api_key: api_token.token
    end

    it 'returns the project' do
      expected = Entities::Project.new(project, type: :full).as_json

      expect(JSON.parse(response.body).symbolize_keys).to eq(expected)
    end

    context 'when api token is invalid' do
      let(:api_token) { double :api_token, token: 'foo' }

      it 'returns a authorization error' do
        expect(response.body).to match(/Invalid token/)
      end
    end

    context 'when api token is linked with a team' do
      let(:some_team) { create :team }
      let(:api_token) { create :api_token, team: some_team }


      it 'returns a authorization error' do
        expect(response.body).to match(/Invalid team/)
      end
    end
  end

  describe '#GET /api/v1/projects/{slug}/analysis' do
    let(:project) { create :project }
    let(:date_for_iteration_number) { Time.new(2016, 12, 1) }
    let(:backlog_date) { Date.new(2016, 12, 13) }
    let(:worst_backlog_date) { Time.new(2016, 12, 13) }
    let(:next_iteration_date) { Time.new(2016, 12, 12) }
    let(:current_iteration_date) { Date.new(2016, 12, 5) }

    let(:iteration) do
      double(
        :iteration,
        velocity: 10,
        volatility: 0,
        current_iteration_number: 32,
        current_iteration_date: current_iteration_date,
        next_iteration_date: next_iteration_date,
        iteration_length: 1,
        date_for_iteration_number: date_for_iteration_number,
        backlog: [1, 2, 3],
        backlog_iterations: [3, 2, 1],
        current_iteration_details: {
          "started": 8,
          "finished": 5
        },
        backlog_date: [59, backlog_date],
        worst_backlog_date: [2, worst_backlog_date]
      )
    end

    let(:expected) do
      {
        "velocity" => 10,
        "volatility" => 0,
        "current_iteration_number" => 1,
        "current_iteration_date" => current_iteration_date.strftime("%Y/%m/%d %H:%M:%S -0200"),
        "next_iteration_date" => next_iteration_date.strftime("%Y/%m/%d %H:%M:%S -0200"),
        "iteration_length" => 1,
        "backlog" =>  [],
        "backlog_iterations" => [[], []],
        "current_iteration_details" => {"started"=>0, "finished"=>0, "delivered"=>0, "accepted"=>0, "rejected"=>0},
        "backlog_date" => [2, backlog_date.strftime("%Y/%m/%d %H:%M:%S -0200")],
        "worst_backlog_date" => [2, worst_backlog_date.strftime("%Y/%m/%d %H:%M:%S -0200")]
      }
    end

    before(:each) do
      allow_any_instance_of(Project).to receive(:iteration_service)
        .and_return(iteration)

      get "/api/v1/projects/#{project.slug}/analysis", since: 1, api_key: api_token.token
    end

    it 'returns the project with analysis' do
      expect(JSON.parse(response.body)).to eq(expected)
    end

    context 'when api token is invalid' do
      let(:api_token) { double :api_token, token: 'foo' }

      it 'returns a authorization error' do
        expect(response.body).to match(/Invalid token/)
      end
    end

    context 'when api token is linked with a team' do
      let(:some_team) { create :team }
      let(:api_token) { create :api_token, team: some_team }

      it 'returns a authorization error' do
        expect(response.body).to match(/Invalid team/)
      end
    end
  end

  describe '#GET /api/v1/teams/{slug}/stories' do
    let(:user) { create :user }
    let(:project) { create :project, users: [user] }

    let!(:done_stories) do
      create_list :story, 2,
                  state: :accepted,
                  project: project,
                  requested_by: user,
                  accepted_at: 5.days.ago,
                  created_at: 10.days.ago

      create_list :story, 2,
                  state: :accepted,
                  project: project,
                  requested_by: user,
                  accepted_at: 6.days.ago,
                  created_at: 10.days.ago
    end

    let!(:in_progress_stories) do
      create_list :story, 3,
                  state: :started,
                  project: project,
                  requested_by: user,
                  created_at: 11.days.ago
    end

    let!(:backlog_stories) do
      create_list :story, 2,
                  state: :unstarted,
                  project: project,
                  requested_by: user,
                  created_at: 12.days.ago

      create_list :story, 2,
                  state: :unstarted,
                  project: project,
                  requested_by: user,
                  created_at: 13.days.ago
    end

    let!(:chillybin_stories) do
      create_list :story, 5,
                  state: :unscheduled,
                  project: project,
                  requested_by: user,
                  created_at: 13.days.ago
    end

    context 'filtering by page' do
      before(:each) do
        get "/api/v1/projects/#{project.slug}/stories", per_page: 3, api_key: api_token.token
      end

      it 'returns 3 project stories' do
        expect(JSON.parse(response.body).count).to eq(3)
      end
    end

    context 'filtering by done state' do
      before(:each) do
        get "/api/v1/projects/#{project.slug}/stories", state: :done, api_key: api_token.token
      end

      it 'returns 4 done project stories' do
        expect(JSON.parse(response.body).count).to eq(4)
      end
    end

    context 'filtering by in progress state' do
      before(:each) do
       get "/api/v1/projects/#{project.slug}/stories",
           state: :in_progress,
           api_key: api_token.token
      end

      it 'returns 3 in progress project stories' do
        expect(JSON.parse(response.body).count).to eq(3)
      end
    end

    context 'filtering by backlog state' do
      before(:each) do
        get "/api/v1/projects/#{project.slug}/stories",
            state: :backlog,
            api_key: api_token.token
      end

      it 'returns 4 backlog project stories' do
        expect(JSON.parse(response.body).count).to eq(4)
      end
    end

    context 'filtering by chilly bin state' do
      before(:each) do
        get "/api/v1/projects/#{project.slug}/stories",
            state: :chilly_bin,
            api_key: api_token.token
      end

      it 'returns 5 chilly bin project stories' do
        expect(JSON.parse(response.body).count).to eq(5)
      end
    end

    context 'filtering by an invalid state' do
      before(:each) do
        get "/api/v1/projects/#{project.slug}/stories",
            state: :foo,
            api_key: api_token.token
      end

      it 'returns an error' do
        expect(JSON.parse(response.body))
          .to eq({ 'error' => 'state does not have a valid value' })
      end
    end

    context 'filtering by created at' do
      before(:each) do
        get "/api/v1/projects/#{project.slug}/stories",
            created_at: 12.days.ago,
            api_key: api_token.token
      end

      it 'returns 2 project stories' do
        expect(JSON.parse(response.body).count).to eq(2)
      end
    end

    context 'filtering by accepted at' do
      before(:each) do
        get "/api/v1/projects/#{project.slug}/stories",
            accepted_at: 5.days.ago,
            state: :done,
            api_key: api_token.token
      end

      it 'returns 2 project stories' do
        expect(JSON.parse(response.body).count).to eq(2)
      end
    end

    context 'when api token is invalid' do
      let(:api_token) { double :api_token, token: 'foo' }

      before(:each) do
        get "/api/v1/projects/#{project.slug}/stories",
            state: :done,
            api_key: api_token.token
      end

      it 'returns a authorization error' do
        expect(response.body).to match(/Invalid token/)
      end
    end

    context 'when api token is linked with a team' do
      let(:some_team) { create :team }
      let(:api_token) { create :api_token, team: some_team }

      before(:each) do
        get "/api/v1/projects/#{project.slug}/stories",
            state: :done,
            api_key: api_token.token
      end

      it 'returns a authorization error' do
        expect(response.body).to match(/Invalid team/)
      end
    end
  end

  describe '#GET /api/v1/projects/{slug}/users' do
    let(:users) { create_list :user, 4 }
    let(:project) { create :project, users: users }

    before(:each) do
      get "/api/v1/projects/#{project.slug}/users",
          per_page: 2,
          api_key: api_token.token
    end

    it 'returns 2 project users' do
      expect(JSON.parse(response.body).count).to eq(2)
    end

    context 'when api token is invalid' do
      let(:api_token) { double :api_token, token: 'foo' }

      it 'returns a authorization error' do
        expect(response.body).to match(/Invalid token/)
      end
    end

    context 'when api token is linked with a team' do
      let(:some_team) { create :team }
      let(:api_token) { create :api_token, team: some_team }

      it 'returns a authorization error' do
        expect(response.body).to match(/Invalid team/)
      end
    end
  end
end
