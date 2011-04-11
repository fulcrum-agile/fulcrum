# Create a user

user = User.create! :email => 'test@example.com', :password => 'testpass'
user.confirm!

project = Project.create! :name => 'Test Project', :users => [user]
