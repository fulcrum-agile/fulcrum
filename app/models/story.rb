class Story < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search,
    :against => {
      title: 'A',
      description: 'B'
    },
    :using => {
      :tsearch => {
        :prefix     => true,
        :negation   => true,
        :any_word   => true,
        :dictionary => "portuguese"
      }
    }

  JSON_ATTRIBUTES = [
    "title", "accepted_at", "created_at", "updated_at", "description",
    "project_id", "story_type", "owned_by_id", "requested_by_id",
    "owned_by_name", "owned_by_initials",  "requested_by_name", "estimate",
    "state", "position", "id", "labels"
  ]
  JSON_METHODS = [
    "errors", "notes", "documents", "tasks"
  ]
  CSV_HEADERS = [
    "Id", "Story","Labels","Iteration","Iteration Start","Iteration End",
    "Story Type","Estimate","Current State","Created at","Accepted at",
    "Deadline","Requested By","Owned By","Description","URL"
  ]

  has_attachments :documents, accept: [:raw, :jpg, :png, :psd, :docx, :xlsx, :doc, :xls, :pdf], maximum: 10

  belongs_to :project
  validates_presence_of :project

  validates :title, :presence => true
  validate :bug_chore_estimation

  belongs_to :requested_by, :class_name => 'User'
  validates :requested_by_id, :belongs_to_project => true

  belongs_to :owned_by, :class_name => 'User'
  validates :owned_by_id, :belongs_to_project => true

  has_many :changesets, :dependent => :destroy
  has_many :tasks, :dependent => :destroy
  has_many :notes, -> { order(:created_at) }, :dependent => :destroy do

    # Creates a collection of rows on this story from a CSV::Row instance
    # Each 'Note' field in the CSV will usually be in the following format:
    #
    #   "This is the note body text (Note Author - Dec 25, 2011)"
    #
    # This method will attempt to set the user and created_at timestamps
    # according to the values in the parens.  If the parens are missing, or
    # their contents cannot be matched or parsed, user and created_at will
    # not be set.
    def from_csv_row(row)
      # Ensure no email notifications get sent during CSV import
      project = proxy_association.owner.project
      project.suppress_notifications

      # Each row can have muliple Note headers.  Extract any of them from
      # this row.
      notes = []
      row.each do |header, value|
        if %w{Note Comment}.include?(header) && value
          next if value.blank? || value =~ /^Commit by/
          value.gsub!("\n", "")
          next unless matches = /(.*)\((.*) - (.*)\)$/.match(value)
          next if matches[1].strip.blank?
          note = build(:note => matches[1].strip,
            :user => project.users.find_by_name(matches[2]),
            :user_name => matches[2],
            :created_at => matches[3])
          notes << note
        end
      end
      notes
    end

  end

  # This attribute is used to store the user who is acting on a story, for
  # example delivering or modifying it.  Usually set by the controller.
  attr_accessor :acting_user

  STORY_TYPES = [
    'feature', 'chore', 'bug', 'release'
  ]

  ESTIMABLE_TYPES = [
    'feature', 'release'
  ]

  validates :story_type, :inclusion => STORY_TYPES

  validates :estimate, :estimate => true, :allow_nil => true

  before_validation :set_position_to_last
  before_save :set_accepted_at
  before_save :cache_user_names

  # Scopes for the different columns in the UI
  scope :done, -> { where(:state => :accepted) }
  scope :in_progress, -> { where(:state => [:started, :finished, :delivered]) }
  scope :backlog, -> { where(:state => :unstarted) }
  scope :chilly_bin, -> { where(:state => :unscheduled) }
  scope :by_label, -> (label) { find_by_sql ["select s.* from stories s, (select regexp_split_to_table(labels, ',') l, id from stories)
      AS labels where labels.l = ? and labels.id = s.id;", label] }

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
      requested_by_name,        # Requested By
      owned_by_name,            # Owned By
      description,              # Description
      nil                       # URL
    ].concat(notes.map(&:to_s))
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
    return true unless project
    last = project.stories.order(position: :desc).first
    self.position = last ? ( last.position + 1 ) : 1
  end

  # The list of users that should be notified when a new note is added to this
  # story.  Includes the requestor, the owner, and any other users who have
  # added notes to the story.
  def notify_users
    ([requested_by, owned_by] + notes.map(&:user)).compact.uniq
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

    def cache_user_names
      self.requested_by_name = requested_by.name unless requested_by.nil?
      if owned_by.present?
        self.owned_by_name     = owned_by.name
        self.owned_by_initials = owned_by.initials
      end
    end

    def bug_chore_estimation
      if !ESTIMABLE_TYPES.include?(story_type) && estimated?
        errors.add(:estimate, :cant_estimate)
      end
    end
end
