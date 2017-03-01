class V1::BaseAPI < Grape::API
  prefix 'api/v1'

  mount V1::Health
  mount V1::Teams
  mount V1::Projects
  mount V1::Users
end
