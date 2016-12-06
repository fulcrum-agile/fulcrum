class API < Grape::API
  format :json
  prefix 'api'

  mount V1::BaseAPI

  add_swagger_documentation \
    mount_path: '/api-docs',
    hide_documentation_path: true,
    hide_format: true,
    include_base_url: true,
    doc_version: '1.0.0',
    info: {
      title: 'Central API'
    }
end
