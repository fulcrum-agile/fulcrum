class StoryUpdaterService
  def self.save(*args)
    new(*args).save
  end

  def initialize(story, params = {})
    @story = story
    @params = params
  end

  def save
    ActiveRecord::Base.transaction do
      assign_attributes
      story.save!
      story.changesets.create!
      notify_users
    end
    story
  rescue ActiveRecord::RecordInvalid
    return false
  end

  private

  attr_reader :story, :params, :users_to_notify

  def assign_attributes
    params.each do |param, value|
      story.public_send("#{param}=", value)
    end
  end

  def notify_users
    return unless can_notify_mentioned_users?

    Notifications.story_mention(story, users_to_notify).deliver
  end

  def users_from_story
    usernames = UsernameParser.parse(story.description)
    return [] if usernames.empty?

    @users_to_notify ||= story.users.where(username: usernames).all
  end

  def can_notify_mentioned_users?
    story.description.present? && users_from_story.any? &&
      !story.suppress_notifications
  end
end
