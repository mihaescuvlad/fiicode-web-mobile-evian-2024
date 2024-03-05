class User::PostsController < UserApplicationController
  def index
    redirect_to action: :following
  end

  def following
    @posts = Post.recommend_following(current_user)
  end

  def new
    @response_to = nil
    if params[:response_to].present?
      @response_to = Post.find(params[:response_to]) rescue not_found
    end
  end

  def create
    post = Post.create!(author: current_user, title: params[:title], content: params[:content])

    redirect_to "/hub/post/#{post.id}"
  end
end
