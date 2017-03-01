class V1::Users < Grape::API
  before do
    authenticate!
  end

  desc 'Return all users', { tags: ['user'] }
  params do
    optional :created_at, type: DateTime
  end
  paginate
  get '/users/' do
    users = User.all
    users = users.where("created_at > ?", params[:created_at]) if params[:created_at]

    present paginate(users), with: Entities::User
  end
end
