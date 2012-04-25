ActiveSupport.use_standard_json_time_format = false

module Fulcrum
  def self.devise_modules
    standard = [:database_authenticatable, :registerable, :confirmable,
                :recoverable, :rememberable, :trackable, :validatable]
    cloudfuji = [:cloudfuji_authenticatable, :trackable, :token_authenticatable]

    ::Cloudfuji::Platform.on_cloudfuji? ? cloudfuji : standard
  end
end

