class User::SessionsController < UserApplicationController
  before_action :authenticate_user!, only: %i[logout]
  before_action :prevent_access_for_authenticated_user!, only: %i[login register]

  def login
    if request.post?
      login = Login.authenticate(params[:email], params[:password])
      if login
        session[:login_id] = login.id
        session[:expires_at] = Time.current + 24.hour
        redirect_to root_path
      else
        render json: { message: "Invalid credentials" }, status: :unauthorized and return
      end
    end
  end

  def register
    if request.post?
      begin
        login = Login.new(email: params[:email])
        login.set_password(params[:password])
        if login.save!
          session[:login_id] = login.id
          session[:expires_at] = Time.current + 24.hour
          redirect_to root_path and return
        end
      rescue Mongoid::Errors::Validations => e
        puts e # TODO: Add alert
      end
      # user = User.new(user_params)
      # TODO: User logic
      redirect_to root_path and return
    end

  end

  def logout

  end

  private

  def user_params
    params.permit(:name, :country, :city)
  end

end