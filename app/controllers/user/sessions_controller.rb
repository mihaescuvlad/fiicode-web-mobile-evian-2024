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
        login = Login.new(email: params[:email])
        login.set_password(params[:password])
        if login.save!
          session[:login_id] = login.id
          session[:expires_at] = Time.current + 24.hour
        end
      rescue Mongoid::Errors::Validations => e
        render json: { message: "Invalid data" }, status: :unauthorized and return
      end
      user = User.new(name: params[:name], login_id: login._id)
      user.save!
      login.update_attribute(:user_id, user._id)

      redirect_to '/' and return
    end

  end

  def logout

  end
end