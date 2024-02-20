class User::WelcomeController < UserApplicationController
  def index
  end

  def greeting
    name = params[:name]
    render json: { message: "Hello, #{name}!" }, status: :bad_request
  end
end
