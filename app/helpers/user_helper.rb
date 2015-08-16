module UserHelper

  def return_user_object(user)
    {
      id: user.id,
      account: user.account,
      username: user.username,
      email: user.email,
      token: user.token
      }
  end
end
