class V1::BaseAPI < Grape::API
  prefix 'api/v1'

  mount V1::Health
end
