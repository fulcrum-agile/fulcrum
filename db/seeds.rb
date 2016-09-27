ActiveRecord::Base.transaction do
  user = User.create!(
    name: 'Foo Bar',
    initials: 'FB',
    username: 'foobar',
    email: 'foo@bar.com',
    password: 'asdfasdf',
  )

  user.confirm!

  project = Project.create!(
    name: 'Test Project',
    users: [user],
    start_date: Time.now,
  )

  project.stories.create!(
    title: "A user should be able to create features",
    story_type: 'feature',
    requested_by: user,
    labels: 'features',
  )

  project.stories.create!(
    title: "A user should be able to create bugs",
    story_type: 'bug',
    requested_by: user,
    labels: 'bugs',
  )

  project.stories.create!(
    title: "A user should be able to create chores",
    story_type: 'chore',
    requested_by: user,
    labels: 'chores',
  )

  project.stories.create!(
    title: "A user should be able to create releases",
    story_type: 'release',
    requested_by: user,
    labels: 'releases',
  )

  project.stories.create!(
    title: "A user should be able to estimate features",
    story_type: 'feature',
    requested_by: user,
    estimate: 1,
    labels: 'estimates,features',
  )


  2.times do |n|
    project.stories.first.notes.create!(
      note: "This is comment number #{n + 1}",
      user: user,
    )
  end


  team = Team.create! name: 'Default'
  team.enrollments.create! user: user, is_admin: true
  team.projects << project


  AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
end
