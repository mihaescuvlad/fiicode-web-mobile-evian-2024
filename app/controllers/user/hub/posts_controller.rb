class User::Hub::PostsController < UserApplicationController
  def show
    @post = Post.find(params[:id.to_s]) rescue not_found
    @post.view(current_user)
  end

  def new
    @response_to = nil
    if params[:response_to].present?
      @response_to = Post.find(params[:response_to]) rescue not_found
    end
  end

  def create
    post = Post.new(author: current_user, title: params[:title], content: params[:content])
    if params[:response_to_id].present?
      post.response_to = Post.find(params[:response_to_id]) rescue not_found
    end
    post.save!

    redirect_to user_hub_post_path(post)
  end
end
