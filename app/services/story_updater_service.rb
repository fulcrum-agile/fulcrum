class StoryUpdaterService
  include ActionController::UrlFor
  include Rails.application.routes.url_helpers

  def self.save(*args)
    new(*args).save
  end

  def initialize(story, params = {})
    @story = story
    @params = params.to_hash
  end

  def save
    ActiveRecord::Base.transaction do
      if story.new_record?
        story.save!
      else
        story.update_attributes!(params)
      end
      story.changesets.create!

      fix_project_start_date
      fix_story_accepted_at

      notify_state_changed
      notify_users
    end
    story
  rescue ActiveRecord::RecordInvalid
    return false
  end

  private

  attr_reader :story, :params, :users_to_notify

  #
  # Members being mentioned in story description
  #

  def notify_users
    return unless can_notify_mentioned_users?

    notifier = Notifications.story_mention(story, users_to_notify)
    notifier.deliver if notifier
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

  #
  # story state change notifications
  #

  def notify_state_changed
    return unless can_notify_state_changed?

    notifier = Notifications.public_send(story.state.to_sym, story, story.acting_user)
    notifier.deliver if notifier
    IntegrationWorker.perform_async(story.project.id, integration_message)
  end

  def can_notify_state_changed?
    return false unless story.state_changed?
    return false if story.suppress_notifications
    return false unless story.acting_user

    actor = nil
    case story.state
    when 'started', 'delivered'
      actor = story.requested_by
      return false unless actor.email_delivery?
    when 'accepted'
      actor = story.owned_by
      return false unless actor.email_acceptance?
    when 'rejected'
      actor = story.owned_by
      return false unless actor.email_rejection?
    else
      return false
    end

    story.acting_user != actor
  end

  def integration_message
    story_link = "#{story.base_uri}#story-#{story.id}"

    case story.state
    when 'started'
      "[#{story.project.name}] The story ['#{story.title}'](#{story_link}) has been started."
    when 'delivered'
      "[#{story.project.name}] The story ['#{story.title}'](#{story_link}) has been delivered for acceptance."
    when 'accepted'
      "[#{story.project.name}] #{story.acting_user.name} ACCEPTED your story ['#{story.title}'](#{story_link})."
    when 'rejected'
      "[#{story.project.name}] #{story.acting_user.name} REJECTED your story ['#{story.title}'](#{story_link})."
    end
  end

  #
  # legacy project start_date and story accepted_at date fixes
  # this possibly exists because of inconsistent data from import
  #

  def fix_project_start_date
    return unless story.state_changed?
    # Set the project start date to today if the project start date is nil
    # and the state is changing to any state other than 'unstarted' or
    # 'unscheduled'
    # FIXME Make model method on Story
    if story.project && !story.project.start_date && !['unstarted', 'unscheduled'].include?(story.state)
      story.project.update_attribute :start_date, Date.today
    end
  end

  def fix_story_accepted_at
    # If a story's 'accepted at' date is prior to the project start date,
    # the project start date should be moved back accordingly
    if story.accepted_at_changed? && story.accepted_at && story.accepted_at < story.project.start_date
      story.project.update_attribute :start_date, story.accepted_at
    end
  end
end
