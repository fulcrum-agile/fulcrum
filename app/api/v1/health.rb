class V1::Health < Grape::API
  desc "Returns 'ok' if API is running properly", { tags: ['health'] }
  get :health do
    { status: 'ok' }
  end
end
