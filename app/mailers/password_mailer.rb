class PasswordMailer < ActionMailer::Base
  default from: "mikazuki.ttp@gmail.com"

  def send_rest_password(user)
    @user = user
    mail(to: @user.email, subject: 'パスワードの再設定')
  end
end
