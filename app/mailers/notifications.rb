class Notifications < ActionMailer::Base
  include Sidekiq::Mailer if Rails.env.production?

  delegate :name, to: :project, prefix: true

  def started(story_id, user_id)
    @story = Story.find(story_id)
    @user = User.find(user_id)

    mail to: @story.requested_by.email, from: @user.email,
      subject: "[#{@story.project.name}] Your story '#{@story.title}' has been started."
  end

  def delivered(story_id, user_id)
    @story = Story.find(story_id)
    @user = User.find(user_id)

    mail to: @story.requested_by.email, from: @user.email,
      subject: "[#{@story.project.name}] Your story '#{@story.title}' has been delivered for acceptance."
  end

  def accepted(story_id, user_id)
    @story = Story.find(story_id)
    @user = User.find(user_id)

    mail to: @story.owned_by.email, from: @user.email,
      subject: "[#{@story.project.name}] #{@user.name} ACCEPTED your story '#{@story.title}'."
  end

  def rejected(story_id, user_id)
    @story = Story.find(story_id)
    @user = User.find(user_id)

    mail to: @story.owned_by.email, from: @user.email,
      subject: "[#{@story.project.name}] #{@user.name} REJECTED your story '#{@story.title}'."
  end

  # Send notification to of a new note to the listed users
  def new_note(note_id, notify_users)
    @note = Note.includes(:story).find(note_id)
    @story = @note.story

    mail to: notify_users, from: @note.user.email,
      subject: "[#{@story.project.name}] New comment on '#{@story.title}'"
  end

  def story_mention(story_id, users_to_notify)
    @story = Story.find(story_id)

    mail to: users_to_notify, from: @story.requested_by.email,
      subject: "[#{@story.project.name}] New mention on '#{@story.title}'"
  end
end
