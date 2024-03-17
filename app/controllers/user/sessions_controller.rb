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
        if params[:password] != params[:password_confirmation]
          render json: { message: "Passwords do not match" }, status: :bad_request and return
        end
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

  def recover_account
  end

  def confirm_email
    @login = Login.find_by(confirm_email_key: params[:token]) rescue not_found
    @login.confirm_email
    @login.save!
  end

  def request_password_reset
    if params[:login].present?
      login = Login.find(params[:login]) rescue (render json: { message: "Invalid login" }, status: :not_found and return)
    else
      login = Login.find_by(email: params[:email]) rescue (render json: { message: "No account found with this email address" }, status: :not_found and return)
    end
    User::LoginMailer.with(login: login).reset_password_email.deliver_now
    render json: { message: "We've mailed you the instructions to recover your account." }, status: :ok and return
    redirect_to '/', notice: "We've mailed you the instructions to recover your account."
  end
end