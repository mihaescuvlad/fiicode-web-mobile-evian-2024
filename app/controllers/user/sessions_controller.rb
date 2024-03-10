class User::SessionsController < UserApplicationController
  before_action :authenticate_user!, only: %i[logout]
  before_action :prevent_access_for_authenticated_user!, only: %i[login register]

  def login
    if request.post?
      login = Login.authenticate_by_email(params[:email], params[:password])
      if login
        session[:login_id] = login.id
        session[:expires_at] = Time.current + 24.hour
        redirect_to '/', notice: "Glad to have you back, #{login.user.last_name}!" and return
      else
        render json: { message: "Invalid credentials" }, status: :unauthorized and return
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
        session[:login_id] = login.id
        session[:expires_at] = Time.current + 24.hour

        User.create!(first_name: params[:first_name], last_name: params[:last_name], login: login)
        login.save!
        redirect_to '/', notice: "Welcome, #{login.user.last_name}!" and return
      rescue Mongoid::Errors::Validations => e
        render json: { message: "Email or username are already used, try again!" }, status: :unauthorized and return
      rescue ArgumentError => e
        render json: { message: e.message }, status: :bad_request and return
      end

    end

  end
end