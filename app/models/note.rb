class Note < ActiveRecord::Base
  belongs_to :user
  belongs_to :story

  attr_accessible :note

  after_save :create_changeset

  validates :note, :presence => true

  def create_changeset
    story.changesets.create!

    # Notify all stakeholders in the story, but not the user who made the
    # note.
    notify_users = story.notify_users
    notify_users.delete(user)

    Notifications.new_note(self, notify_users).deliver unless notify_users.empty?
  end

  # Defines the attributes and methods that are included when calling to_json
  def as_json(options = {})
    super(:methods => ["errors"])
  end
end
