ActiveSupport.use_standard_json_time_format = false

module Fulcrum
  def self.devise_modules
    standard = [:database_authenticatable, :registerable, :confirmable,
                :recoverable, :rememberable, :trackable, :validatable]
    bushido = [:bushido_authenticatable, :trackable, :token_authenticatable]

    ::Bushido::Platform.on_bushido? ? bushido : standard
  end
end

