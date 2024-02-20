class User::WelcomeController < UserApplicationController
  def index
    clear_session
  end
end
