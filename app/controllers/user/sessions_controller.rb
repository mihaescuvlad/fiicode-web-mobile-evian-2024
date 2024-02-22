class User::SessionsController < UserApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, only: %i[logout]
  before_action :prevent_access_for_authenticated_user!, only: %i[login register]

  def login
    if request.post?
      begin
        req_body = JSON.parse request.body.read
      rescue JSON::ParserError => e
        puts e
        render json: { message: "Invalid JSON" }, status: :bad_request and return
      end

      login = Login.authenticate(req_body[:email.to_s], req_body[:password.to_s])
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