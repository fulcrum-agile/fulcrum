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
end
