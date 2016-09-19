class Story < ActiveRecord::Base
  include Central::Support::StoryConcern::Attributes
  include Central::Support::StoryConcern::Associations
  include Central::Support::StoryConcern::Validations
  include Central::Support::StoryConcern::Transitions
  include Central::Support::StoryConcern::Scopes
  include Central::Support::StoryConcern::Callbacks
  include Central::Support::StoryConcern::CSV

  module ReadOnlyDocuments
    def documents=(attachments)
      raise ActiveRecord::ReadOnlyRecord if readonly?
      # convert from ActionController::Parameters which doesn't have symbolize_keys!
      super(attachments.map { |hash| hash.to_hash })
    end

    def documents_attributes
      documents.map(&:public_id)
    end
  end

  has_attachments :documents, accept: [:raw, :jpg, :png, :psd, :docx, :xlsx, :doc, :xls, :pdf], maximum: 10
  attr_accessor :documents_attributes_was
  prepend ReadOnlyDocuments

  include PgSearch
  pg_search_scope :search,
    against: {
      title: 'A',
      description: 'B',
      labels: 'C'
    },
    using: {
      tsearch: {
        prefix: true,
        negation: true
      }
    }

  pg_search_scope :search_labels,
    against: :labels,
    ranked_by: ":trigram"

  JSON_ATTRIBUTES = [
    "title", "accepted_at", "created_at", "updated_at", "description",
    "project_id", "story_type", "owned_by_id", "requested_by_id",
    "owned_by_name", "owned_by_initials",  "requested_by_name", "estimate",
    "state", "position", "id", "labels"
  ]
  JSON_METHODS = [
    "errors", "notes", "documents", "tasks"
  ]

  # Returns true or false based on whether the story has been estimated.
  def estimated?
    !estimate.nil?
  end
  alias :estimated :estimated?

  # Returns true if this story can have an estimate made against it
  def estimable?
    feature? && !estimated?
  end
  alias :estimable :estimable?

  # Returns the CSS id of the column this story belongs in
  def column
    case state
    when 'unscheduled'
      '#chilly_bin'
    when 'unstarted'
      '#backlog'
    when 'accepted'
      if iteration_service
        if iteration_service.current_iteration_number == iteration_service.iteration_number_for_date(accepted_at)
          return '#in_progress'
        end
      end
      '#done'
    else
      '#in_progress'
    end
  end

  def as_json(options = {})
    super(only: JSON_ATTRIBUTES, methods: JSON_METHODS)
  end

  # The list of users that should be notified when a new note is added to this
  # story.  Includes the requestor, the owner, and any other users who have
  # added notes to the story.
  def stakeholders_users
    ([requested_by, owned_by] + notes.map(&:user)).compact.uniq
  end

  def readonly?
    !accepted_at_changed? && accepted_at.present?
  end

  def cycle_time_in(unit = :days)
    raise 'wrong unit' unless %i[days weeks months years].include?(unit)
    ( cycle_time / 1.send(unit) ).round
  end

end
