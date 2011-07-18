class Notifications < ActionMailer::Base

  def delivered(story, delivered_by)
    @story = story
    @delivered_by = delivered_by

    mail :to => story.requested_by.email, :from => delivered_by.email,
      :subject => "[#{story.project.name}] Your story '#{story.title}' has been delivered for acceptance."
  end
end
