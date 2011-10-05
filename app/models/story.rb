class Story < ActiveRecord::Base

  JSON_ATTRIBUTES = [
    "title", "accepted_at", "created_at", "updated_at", "description",
    "project_id", "story_type", "owned_by_id", "requested_by_id", "estimate",
    "state", "position", "id", "events", "estimable", "estimated", "labels"
  ]
  JSON_METHODS = [
    "events", "estimable", "estimated", "errors"
  ]
  CSV_HEADERS = [
    "Id", "Story","Labels","Iteration","Iteration Start","Iteration End",
    "Story Type","Estimate","Current State","Created at","Accepted at",
    "Deadline","Requested By","Owned By","Description","URL","Note"
  ]

  belongs_to :project
  validates_presence_of :project_id

  validates :title, :presence => true

  belongs_to :requested_by, :class_name => 'User'
  validates :requested_by_id, :belongs_to_project => true

  belongs_to :owned_by, :class_name => 'User'
  validates :owned_by_id, :belongs_to_project => true

  has_many :changesets

  # This attribute is used to store the user who is acting on a story, for
  # example delivering or modifying it.  Usually set by the controller.
  attr_accessor :acting_user

  STORY_TYPES = [
    'feature', 'chore', 'bug', 'release'
  ]
  validates :story_type, :inclusion => STORY_TYPES

  validates :estimate, :estimate => true, :allow_nil => true

  before_validation :set_position_to_last
  before_save :set_accepted_at

  # Scopes for the different columns in the UI
  scope :done, where(:state => :accepted)
  scope :in_progress, where(:state => [:started, :finished, :delivered])
  scope :backlog, where(:state => :unstarted)
  scope :chilly_bin, where(:state => :unscheduled)

  include ActiveRecord::Transitions
  state_machine do
    state :unscheduled
    state :unstarted
    state :started
    state :finished
    state :delivered
    state :accepted
    state :rejected

    event :start do
      transitions :to => :started, :from => [:unstarted, :unscheduled]
    end

    event :finish do
      transitions :to => :finished, :from => :started
    end

    event :deliver do
      transitions :to => :delivered, :from => :finished
    end

    event :accept do
      transitions :to => :accepted, :from => :delivered
    end

    event :reject do
      transitions :to => :rejected, :from => :delivered
    end

    event :restart do
      transitions :to => :started, :from => :rejected
    end
  end

  # Returns an array, in the correct order, of the headers to be added to
  # a CSV render of a list of stories
  def self.csv_headers
    CSV_HEADERS
  end

  def to_s
    title
  end

  def to_csv
    [
      id,                       # Id
      title,                    # Story
      labels,                   # Labels
      nil,                      # Iteration
      nil,                      # Iteration Start
      nil,                      # Iteration End
      story_type,               # Story Type
      estimate,                 # Estimate
      state,                    # Current State
      created_at,               # Created at
      accepted_at,              # Accepted at
      nil,                      # Deadline
      requested_by.try(:name),  # Requested By
      owned_by.try(:name),      # Owned By
      description,              # Description
      nil,                      # URL
      nil                       # Note
    ]
  end

  # Returns the list of state change events that can operate on this story,
  # based on its current state
  def events
    self.class.state_machine.events_for(current_state)
  end

  # Returns true or false based on whether the story has been estimated.
  def estimated?
    !estimate.nil?
  end
  alias :estimated :estimated?

  # Returns true if this story can have an estimate made against it
  def estimable?
    story_type == 'feature' && !estimated?
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
      '#done'
    else
      '#in_progress'
    end
  end

  def as_json(options = {})
    super(:only => JSON_ATTRIBUTES, :methods => JSON_METHODS)
  end

  def set_position_to_last
    return true if position
    last = project.stories.first(:order => 'position DESC')
    if last
      self.position = last.position + 1
    else
      self.position = 1
    end
  end

  private

    def set_accepted_at
      if state_changed?
        if state == 'accepted' && accepted_at == nil
          # Set accepted at to today when accepted
          self.accepted_at = Date.today
        elsif state_was == 'accepted'
          # Unset accepted at when changing from accepted to something else
          self.accepted_at = nil
        end
      end
    end
end
