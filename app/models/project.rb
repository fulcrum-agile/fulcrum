class Project < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  JSON_ATTRIBUTES = [
    "id", "iteration_length", "iteration_start_day", "start_date",
    "default_velocity"
  ].freeze

  JSON_METHODS = ["last_changeset_id", "point_values"].freeze

  # These are the valid point scales for a project. These represent
  # the set of valid points estimate values for a story in this project.
  POINT_SCALES = {
    'fibonacci'     => [1,2,3,5,8].freeze,
    'powers_of_two' => [1,2,4,8].freeze,
    'linear'        => [1,2,3,4,5].freeze,
  }.freeze

  validates_inclusion_of :point_scale, :in => POINT_SCALES.keys,
    :message => "%{value} is not a valid estimation scheme"

  ITERATION_LENGTH_RANGE = (1..4).freeze

  validates_numericality_of :iteration_length,
    :greater_than_or_equal_to => ITERATION_LENGTH_RANGE.min,
    :less_than_or_equal_to => ITERATION_LENGTH_RANGE.max, :only_integer => true,
    :message => "must be between 1 and 4 weeks"

  validates_numericality_of :iteration_start_day,
    :greater_than_or_equal_to => 0, :less_than_or_equal_to => 6,
    :only_integer => true, :message => "must be an integer between 0 and 6"

  validates :name, :presence => true

  validates_numericality_of :default_velocity, :greater_than => 0,
                            :only_integer => true

  has_many :integrations, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :users, -> { uniq }, through: :memberships

  accepts_nested_attributes_for :users, :reject_if => :all_blank

  has_many :stories, :dependent => :destroy do

    # Populates the stories collection from a CSV string.
    def from_csv(csv_string)

      # Eager load this so that we don't have to make multiple db calls when
      # searching for users by full name from the CSV.
      users = proxy_association.owner.users

      csv = CSV.parse(csv_string, :headers => true)
      csv.map do |row|
        row_attrs = row.to_hash
        story = build({
          :title        => ( row_attrs["Title"] || row_attrs["Story"] || "").truncate(255, omission: '...'),
          :story_type   => (row_attrs["Type"] || row_attrs["Story Type"]).downcase,
          :requested_by => users.detect {|u| u.name == row["Requested By"]},
          :owned_by     => users.detect {|u| u.name == row["Owned By"]},
          :accepted_at  => row_attrs["Accepted at"],
          :estimate     => row_attrs["Estimate"],
          :labels       => row_attrs["Labels"],
          :description  => row_attrs["Description"]
        })

        row_state = ( row_attrs["Current State"] || 'unstarted').downcase
        if Story.available_states.include?(row_state.to_sym)
          story.state = row_state
        end
        story.requested_by_name = ( row["Requested By"] || "").truncate(255)
        story.owned_by_name = ( row["Owned By"] || "").truncate(255)
        story.owned_by_initials = ( row["Owned By"] || "" ).split(' ').map { |n| n[0].upcase }.join('')

        tasks = []
        row.each do |header, value|
          tasks << "* #{value}" if header == 'Task' && value
        end
        story.description = "#{story.description}\n\nTasks:\n\n#{tasks.join("\n")}" unless tasks.empty?
        story.project.suppress_notifications = true # otherwise the import will generate massive notifications!
        story.save

        # Generate notes for this story if any are present
        story.notes.from_csv_row(row)

        story
      end
    end

  end
  has_many :changesets, :dependent => :destroy

  attr_writer :suppress_notifications

  scope :with_stories_notes, -> { includes(stories: :notes) }
  scope :not_archived, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }

  has_attachment :import, accept: [:raw]

  def suppress_notifications
    @suppress_notifications || false
  end

  def to_s
    name
  end

  # Returns an array of the valid points values for this project
  def point_values
    POINT_SCALES[point_scale]
  end

  def last_changeset_id
    changesets.last && changesets.last.id
  end

  def as_json(options = {})
    super(:only => JSON_ATTRIBUTES, :methods => JSON_METHODS)
  end

  def csv_filename
    "#{name}-#{Time.now.strftime('%Y%m%d_%I%M')}.csv"
  end

  def archived
    !!(archived_at)
  end

  def archived=(value)
    if !value || value == "0"
      self.archived_at = nil
    else
      self.archived_at = Time.zone.now
    end
  end
end
