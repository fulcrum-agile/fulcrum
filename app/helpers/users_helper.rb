module UsersHelper
  def avatar_url(user)
    user.gravatar_url
  end
end
