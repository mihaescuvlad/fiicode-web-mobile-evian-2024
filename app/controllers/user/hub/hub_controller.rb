class User::Hub::HubController < UserApplicationController
  layout 'user_hub'

  before_action :authenticate_user!, only: [:following]

  def index
    redirect_to action: :following
  end

  def following
    @posts = Post.recommend_following(current_user)
  end

  def for_you
    params[:page] ||= 1
    posts_data = RecommendationsApi.paginated_hub_posts(current_user, params[:page], 10)

    @posts = Post.where(_id: { '$in': posts_data["posts"] })
    @total_pages = posts_data["total_pages"]
  end
  
  def hashtag
    @hashtag = params[:hashtag]
    @posts = Post.where(:hashtags.in => [@hashtag])
                 .top_level
                 .by_notoriety
  end
end