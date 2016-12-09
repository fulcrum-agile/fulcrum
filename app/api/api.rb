class API < Grape::API
  format :json
  prefix 'api'

  helpers do
    include ActionController::HttpAuthentication::Token

    def authenticate!
      error!('Unauthorized. Invalid token.', 401) unless api_key
    end

    def api_key
      @api_key ||= begin
        params[:api_key] ||= token_params_from(headers['Authorization']).shift[1] if headers['Authorization'].present?

        ApiToken.includes(:team).find_by(token: params[:api_key])
      end
    end

    def current_team
      return unless api_key

      api_key.team
    end
  end

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
