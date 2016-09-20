class Project < ActiveRecord::Base
  include Central::Support::ProjectConcern::Attributes
  include Central::Support::ProjectConcern::Associations
  include Central::Support::ProjectConcern::Validations
  include Central::Support::ProjectConcern::Scopes
  include Central::Support::ProjectConcern::CSV::InstanceMethods

  extend FriendlyId
  friendly_id :name, use: :slugged

  JSON_ATTRIBUTES = [
    "id", "iteration_length", "iteration_start_day", "start_date",
    "default_velocity"
  ].freeze

  JSON_METHODS = ["last_changeset_id", "point_values"].freeze

  has_many :integrations, dependent: :destroy
  has_many :changesets, dependent: :destroy

  has_attachment :import, accept: [:raw]

  def last_changeset_id
    changesets.last && changesets.last.id
  end

  def as_json(options = {})
    super(only: JSON_ATTRIBUTES, methods: JSON_METHODS)
  end

  def to_param
    ::FriendlyId::Disabler.disabled? ? (id && id.to_s) : super
  end
end
