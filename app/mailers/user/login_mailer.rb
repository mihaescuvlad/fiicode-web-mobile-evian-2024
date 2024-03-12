class User::LoginMailer < UserApplicationMailer
  def welcome_email
    @login = params[:login]
    @join_url = user_confirm_email_url(token: @login.confirm_email_key)
    mail(to: @login.email, subject: "Hi, #{@login.user.last_name}! Please confirm your account.")
  end
end