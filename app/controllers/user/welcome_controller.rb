class User::WelcomeController < UserApplicationController
  def index
    render plain: "Welcome to the User section!"
  end
end
