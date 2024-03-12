class User::SessionsController < UserApplicationController
  before_action :authenticate_user!, only: %i[logout]
  before_action :prevent_access_for_authenticated_user!, only: %i[login register]

  def login
    if request.post?
      begin
        login = Login.authenticate_by_email(params[:email], params[:password])
        if login
          session[:login_id] = login.id
          session[:expires_at] = Time.current + 24.hour
          redirect_to '/', notice: "Glad to have you back, #{login.user.last_name}!" and return
        else
          render json: { message: "Invalid credentials" }, status: :unauthorized and return
        end
      rescue ArgumentError => e
        render json: { message: e.message }, status: :unauthorized and return
      end
    end
  end

  def logout
    clear_session
    redirect_to '/'
  end

  def register
    if request.post?
      begin
        login = Login.new(params.permit([:username, :email, :password]))
        User.create!(first_name: params[:first_name], last_name: params[:last_name], login: login)
        login.save!
        User::LoginMailer.with(login: login).welcome_email.deliver_now
        redirect_to action: :login, notice: "Account created, please check your email to confirm your account." and return
      rescue Mongoid::Errors::Validations => e
        render json: { message: "Email or username are already used, try again!" }, status: :unauthorized and return
      rescue ArgumentError => e
        render json: { message: e.message }, status: :bad_request and return
      end
    end
  end

  def confirm_email
    @login = Login.find_by(confirm_email_key: params[:token]) rescue not_found
    @login.confirm_email
    @login.save!
  end
end