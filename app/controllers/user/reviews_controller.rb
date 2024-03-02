class User::ReviewsController < UserApplicationController
  def index
    @reviews = Review.all
  end

  def show
  end

  def create
    @review = Review.new(review_params)
  
    respond_to do |format|
      if @review.save
        format.html { redirect_to user_product_path(@review.product_id), notice: 'Review was successfully created.' }
        format.json { render :show, status: :created, location: @review }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end
  

  private

  def review_params
    login_id = session[:login_id]["$oid"]
    user_id = User.find_by(login_id: login_id).id

    product_id = params[:product_id]
    
    review_attributes = params.require(:review).permit(:rating, :comment)
    rating = review_attributes[:rating] == "true" ? true : false
  
    review_params = { 
      rating: rating, 
      comment: review_attributes[:comment], 
      reviewer_id: user_id, 
      product_id: product_id, 
      helpful_votes: 0 
    }
  
    review_params
  end
end
