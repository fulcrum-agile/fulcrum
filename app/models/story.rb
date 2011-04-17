class Story < ActiveRecord::Base
  belongs_to :project
  validates_presence_of :project_id

  belongs_to :requested_by, :class_name => 'User'
  validates :requested_by_id, :belongs_to_project => true

  STORY_TYPES = [
    'feature', 'chore', 'bug', 'release'
  ]
  validates :story_type, :inclusion => STORY_TYPES

  validates :estimate, :estimate => true, :allow_nil => true

  # Scopes for the different columns in the UI
  scope :done, where(:state => :accepted)
  scope :in_progress, where(:state => [:started, :finished, :delivered])
  scope :backlog, where(:state => :unstarted)

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
      transitions :to => :started, :from => [:unstarted, :rejected]
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
  end

  def to_s
    title
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

  # Returns true if this story can have an estimate made against it
  def estimable?
    story_type == 'feature' && !estimated?
  end
end
