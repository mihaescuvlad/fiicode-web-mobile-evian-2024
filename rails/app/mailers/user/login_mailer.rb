class User::LoginMailer < UserApplicationMailer
  def welcome_email
    @login = params[:login]
    @join_url = user_confirm_email_url(token: @login.confirm_email_key)
    mail(to: @login.email, subject: "Hi, #{@login.user.last_name}! Please confirm your account.")
  end

  def reset_password_email
    @login = params[:login]
    @reset_password_url = account_user_profile_url(login: @login.id, token: @login.generate_reset_password_key)
    @login.save!
    mail(to: @login.email, subject: "Reset your password")
  end
end