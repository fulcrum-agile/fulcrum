class RemoveDefaultUsernameFromUsers < ActiveRecord::Migration
  # User with nil username will receive their emails as username:
  # eg:
  #   user.test@gmail.com => user.test
  #   user.test@live.com  => user.test.live
  def up
    User.where(username: '').each do |user|
      username, domain = user.email.split('@')

      user.username =
        if User.where(username: username).empty?
          username
        else
          [username, domain.split('.').first].join('.')
        end

      user.save!
    end

    change_column_default :users, :username, nil
  end

  def down
    change_column_default :users, :username, ''
  end
end
