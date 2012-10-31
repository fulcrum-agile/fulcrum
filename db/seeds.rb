if Rails.env.development?
  # Create a user

  user = User.create! :name => 'Test User', :initials => 'TU',
                      :email => 'test@example.com', :password => 'testpass'
  user.confirm!

  project = Project.create! :name => 'Test Project', :users => [user], :start_date => Time.now

  story = project.stories.create! :title => "A user should be able to create features",
    :story_type => 'feature', :requested_by => user, :labels => 'features'
  project.stories.create! :title => "A user should be able to create bugs",
    :story_type => 'bug', :requested_by => user, :labels => 'bugs'
  project.stories.create! :title => "A user should be able to create chores",
    :story_type => 'chore', :requested_by => user, :labels => 'chores'
  project.stories.create! :title => "A user should be able to create releases",
    :story_type => 'release', :requested_by => user, :labels => 'releases'
  project.stories.create! :title => "A user should be able to estimate features",
    :story_type => 'feature', :requested_by => user, :estimate => 1,
    :labels => 'estimates,features'

  2.times do |n|
    note = story.notes.build :note => "This is comment number #{n + 1}"
    note.user = user
    note.save!
  end
end
