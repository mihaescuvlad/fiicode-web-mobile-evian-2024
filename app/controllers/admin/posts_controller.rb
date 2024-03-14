class Admin::PostsController < AdminApplicationController
  before_action :authenticate_user!

  def index
    if Post.most_flagged.empty?
      @post = nil
      return
    end

    @idx = params[:idx].to_i || 0
    @idx %= Post.most_flagged.length
    @post = Post.most_flagged[@idx]
    @post.review_lock
    @post.save!
  end

  def destroy
    post = Post.find(params[:id]) rescue not_found
    post.destroy!

    redirect_to action: :index, status: :see_other
  end

  def cleanse_reports
    post = Post.find(params[:id]) rescue not_found
    post.reporter_ids = []
    post.save!

    redirect_to action: :index, status: :see_other
  end

  def ignore_post
    post = Post.find(params[:id]) rescue not_found
    post.review_unlock
    post.save!

    redirect_to action: :index, status: :see_other, idx: (params[:idx].present? ? params[:idx].to_i + 1 : 0)
  end
end
