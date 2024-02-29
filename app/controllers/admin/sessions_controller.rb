class Admin::SessionsController < AdminApplicationController
  before_action :authenticate_user!, only: %i[logout]
  before_action :prevent_access_for_authenticated_user!, only: %i[login]

  def login
    if request.post?
      login = Login.authenticate(params[:email], params[:password])
      if login
        session[:login_id] = login.id
        session[:expires_at] = Time.current + 24.hour
        if login.user.administrator?
          redirect_to '/' and return
        else
          clear_session
          render json: { message: "Missing administrator privileges" }, status: :unauthorized and return
        end
      else
        render json: { message: "Invalid credentials" }, status: :unauthorized and return
      end
    end
    render 'user/sessions/login'
  end

  def logout
    clear_session
    redirect_to '/'
  end
end
