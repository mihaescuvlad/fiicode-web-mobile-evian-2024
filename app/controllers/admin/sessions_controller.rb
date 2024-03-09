class Admin::SessionsController < AdminApplicationController
  before_action :authenticate_user!, only: %i[logout]
  before_action :prevent_access_for_authenticated_user!, only: %i[login]

  def login
    if request.post?
      login = Admin.authenticate(params[:user], params[:password])
      if login
        session[:login_id] = login.id
        session[:expires_at] = Time.current + 96.hour

        redirect_to '/' and return
      else
        render json: { message: "Invalid credentials" }, status: :unauthorized and return
      end
    end
  end

  def logout
    clear_session
    redirect_to '/'
  end
end
