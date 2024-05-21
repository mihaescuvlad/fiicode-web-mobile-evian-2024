class User::Hub::RatingsController < UserApplicationController

  def destroy
    head :unauthorized and return unless current_user.present?

    rating = Rating.find_by(user: current_user, post: Post.find(params[:post_id])) rescue nil
    head :not_found and return unless rating
    rating.destroy!
    head :no_content
  end

  def create
    unless current_user.present?
      render json: { message: "You must be logged in to vote." }, status: :unauthorized and return
    end

    unless params[:vote].present? and %w(upvote downvote).include?(params[:vote].to_s)
      head :bad_request and return
    end

    symbol = { "upvote" => :up_vote, "downvote" => :down_vote }[params[:vote]]

    rating = Rating.find_by(user: current_user, post: Post.find(params[:post_id])) rescue nil
    if rating.present?
      rating.vote = symbol
      rating.save!
      render json: rating, status: :ok and return
    end

    rating = Rating.create!(user: current_user, post: Post.find(params[:post_id]), vote: symbol)
    render json: rating, status: :created
  end
end