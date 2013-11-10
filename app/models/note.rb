class Note < ActiveRecord::Base
  belongs_to :user
  belongs_to :story

  after_save :create_changeset

  validates :note, :presence => true

  # FIXME move to observer
  def create_changeset
    story.changesets.create!

    unless story.project.suppress_notifications
      # Notify all stakeholders in the story, but not the user who made the
      # note.
      notify_users = story.notify_users
      notify_users.delete(user)

      Notifications.new_note(self, notify_users).deliver unless notify_users.empty? || user.nil?
    end
  end

  # Defines the attributes and methods that are included when calling to_json
  def as_json(options = {})
    super(:methods => ["errors"])
  end

  def to_s
    note_string = note
    user_name = user ? user.name : I18n.t('author unknown')
    created_date = I18n.l created_at, :format => :note_date
    note_string = note_string + " (" + user_name + " - " + created_date + ")"
  end
end
