class User::SessionsController < UserApplicationController
  before_action :authenticate_user!, only: %i[logout]
  before_action :prevent_access_for_authenticated_user!, only: %i[login register]

  def login
    if request.post?
      login = Login.authenticate(params[:email], params[:password])
      if login
        session[:login_id] = login.id
        session[:expires_at] = Time.current + 24.hour
        redirect_to '/'
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
        login = Login.new(email: params[:email], username: params[:username])
        login.set_password(params[:password])
        if login.save!
          session[:login_id] = login.id
          session[:expires_at] = Time.current + 24.hour
        end
      rescue Mongoid::Errors::Validations => e
        render json: { message: "Email or username are already used, try again!!" }, status: :unauthorized and return
      end
      user = User.new(login_id: login._id, first_name: params[:first_name], last_name: params[:last_name])
      user.save!
      login.update_attribute(:user_id, user._id)

      redirect_to '/' and return
    end

  end
end