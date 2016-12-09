class Team < ActiveRecord::Base
  include Central::Support::TeamConcern::Associations
  include Central::Support::TeamConcern::Validations
  include Central::Support::TeamConcern::Scopes
  include Central::Support::TeamConcern::DomainValidator

  extend FriendlyId
  friendly_id :name, use: :slugged

  has_attachment :logo, accept: [:jpg, :png, :gif, :bmp]

  has_many :api_tokens

  def to_param
    ::FriendlyId::Disabler.disabled? ? (id && id.to_s) : super
  end
end
