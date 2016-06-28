class NoteCreationService
  def self.create(*args)
    new(*args).create
  end

  delegate :user, :story, to: :note

  def initialize(note)
    @note = note
  end

  def create
    ActiveRecord::Base.transaction do
      note.save!
      note.story.changesets.create!
      notify_users
    end
    note
  rescue ActiveRecord::RecordInvalid
    return false
  end

  private

  attr_reader :note

  def notify_users
    return if user.nil?

     users_to_notify = story.stakeholders_users
     users_to_notify.delete(user)

     if users_to_notify.any? && !story.project.suppress_notifications
      Notifications.new_note(note, users_to_notify).deliver
    end
  end
end
