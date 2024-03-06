class User::Hub::HubController < UserApplicationController
  layout 'user_hub'

  before_action :authenticate_user!, only: [:following]

  def index
    redirect_to action: :following
  end

  def following
    @posts = Post.recommend_following(current_user)
  end
end