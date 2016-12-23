class V1::Teams < Grape::API
  resource :teams do
    helpers do
      def authorize_team!
        return unless current_team
        return unless current_team.slug != params[:slug]

        error!('Unauthorized. Invalid team.', 401)
      end
    end

    before do
      authenticate!
      authorize_team!
    end

    desc 'Return all teams', { tags: ['team'] }
    paginate
    get '/' do
      teams = Team.all

      present paginate(teams), with: Entities::Team
    end

    desc 'Return the specified team', { tags: ['team'] }
    get '/:slug' do
      team = Team.find_by_slug(params[:slug])

      present team, with: Entities::Team
    end

    desc 'Return all projects of a specified team', { tags: ['team'] }
    paginate
    get '/:slug/projects' do
      team = Team.includes(:projects).find_by_slug(params[:slug])
      projects = team.projects

      present paginate(projects), with: Entities::Project
    end

    desc 'Return all users of a specified team', { tags: ['team'] }
    paginate
    get '/:slug/users' do
      team = Team.includes(enrollments: [:user]).find_by_slug(params[:slug])
      users = team.users

      present paginate(users), with: Entities::User
    end
  end
end
