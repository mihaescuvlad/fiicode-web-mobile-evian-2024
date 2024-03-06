class User::Hub::RatingsController < UserApplicationController

  def destroy
    rating = Rating.find_by(user: current_user, post: Post.find(params[:post_id])) rescue nil
    head :not_found and return unless rating
    rating.destroy!
    head :no_content
  end

  def create
    unless params[:vote].present? and %w(upvote downvote).include?(params[:vote].to_s)
      head :bad_request and return
    end

    symbol = { "upvote" => :up_vote, "downvote" => :down_vote }[params[:vote]]

    self.destroy

    rating = Rating.create!(user: current_user, post: Post.find(params[:post_id]), vote: symbol)
    render json: rating, status: :created
  end
end