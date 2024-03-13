class User::Hub::PostsController < UserApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def show
    @post = Post.find(params[:id.to_s]) rescue not_found

    @post.view(current_user) if current_user.present?
    @post.save!
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

  def report
    post = Post.find(params[:id.to_s]) rescue (head :not_found and return)
    if current_user.present?
      post.report(current_user)
      post.save!
    else
      head :unauthorized and return
    end

    head :no_content
  end
end
