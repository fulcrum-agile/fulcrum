class Notifications < ActionMailer::Base
  def story_changed(story, actor)
    @story = story
    @actor = actor

    mail_params = MailParams.new(story, actor).send(story.status.to_sym)
    mail mail_params.merge(template_name: story.status)
  end

  # Send notification to of a new note to the listed users
  def new_note(note_id, notify_users)
    @note = Note.includes(:story).find(note_id)
    @story = @note.story

    mail to: notify_users, from: @note.user.email,
      subject: "[#{@story.project.name}] New comment on '#{@story.title}'"
  end

  def story_mention(story, users_to_notify)
    @story = story

    mail to: users_to_notify, from: @story.requested_by.email,
      subject: "[#{@story.project.name}] New mention on '#{@story.title}'"
  end

  private

  class MailParams < Struct.new(:story, :actor)
    def started
      {
        to: story.requested_by.email,
        from: actor.email,
        subject: "[#{story.project.name}] Your story '#{story.title}' has been started."
      }
    end

    def delivered
      {
        to: story.requested_by.email,
        from: actor.email,
        subject: "[#{story.project.name}] Your story '#{story.title}' has been delivered for acceptance."
      }
    end

    def accepted
      {
        to: story.owned_by.email,
        from: actor.email,
        subject: "[#{story.project.name}] #{actor.name} ACCEPTED your story '#{story.title}'."
      }
    end

    def rejected
      {
        to: story.owned_by.email,
        from: actor.email,
        subject: "[#{story.project.name}] #{actor.name} REJECTED your story '#{story.title}'."
      }
    end
  end
end
