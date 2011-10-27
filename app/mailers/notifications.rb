class Notifications < ActionMailer::Base

  def delivered(story, delivered_by)
    @story = story
    @delivered_by = delivered_by

    mail :to => story.requested_by.email, :from => delivered_by.email,
      :subject => "[#{story.project.name}] Your story '#{story.title}' has been delivered for acceptance."
  end

  def accepted(story, accepted_by)
    @story = story
    @accepted_by = accepted_by

    mail :to => story.owned_by.email, :from => accepted_by.email,
      :subject => "[#{story.project.name}] #{accepted_by.name} ACCEPTED your story '#{story.title}'."
  end

  def rejected(story, rejected_by)
    @story = story
    @accepted_by = rejected_by

    mail :to => story.owned_by.email, :from => rejected_by.email,
      :subject => "[#{story.project.name}] #{rejected_by.name} REJECTED your story '#{story.title}'."
  end

  # Send notification to of a new note to the listed users
  def new_note(note, notify_users)
    @note = note
    @story = note.story

    @notify_emails = notify_users.map(&:email)

    mail :to => @notify_emails, :from => @note.user.email,
      :subject => "[#{@story.project.name}] New comment on '#{@story.title}'"
  end
end
