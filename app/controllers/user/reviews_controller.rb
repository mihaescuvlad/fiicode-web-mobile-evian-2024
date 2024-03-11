class User::ReviewsController < UserApplicationController
  before_action :authenticate_user!, only: %i[create edit update destroy]
  before_action :set_product
  before_action :set_review, only: %i[edit update destroy]

  def index
    @reviews = Review.all
  end

  def show
  end

  def edit
  end

  def create
    begin
      @review = Review.new(review_params)

      product = Product.find(@review.product_id)
      product.rating += @review.rating ? 1 : 0
      product.save!

      respond_to do |format|
        if @review.save
          format.html { redirect_to user_product_path(@review.product_id), notice: 'Review was successfully created.' }
          format.json { render :show, status: :created, location: @review }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @review.errors, status: :unprocessable_entity }
        end
      end
    rescue
      render json: { message: "You have to click on the \"Dislike\" or \"Like\" buttons for the product." }, status: :bad_request and return
    end
  end

  def update
    begin
      old_rating = @review.rating
      @review.update!(review_params)

      product = Product.find(@review.product_id)
      product.rating += (old_rating != @review.rating) ? (@review.rating ? 1 : -1) : 0
      product.save!

      redirect_to user_product_path(@review.product_id), method: :get
    rescue
      render json: { message: "Something went wrong with updating your review. Please take a break, read a book and try again later." }, status: :bad_request and return
    end
  end  

  def destroy
    product = Product.find(@review.product_id)
    product.rating += @review.rating ? -1 : 0
    product.save!

    @review.destroy!

    redirect_to user_product_path(@review.product_id)
  end

  private

  def set_product
    @product ||= Product.find(params[:product_id])
  end

  def set_review
    @review ||= Review.find_by(id: params[:id], product_id: @product.id, reviewer_id: current_user.id)
  end

  def review_params
    raise "You have to like or dislike a product." if !params[:thumb_value].in?(["UP", "DOWN"])
    
    rating = params[:thumb_value] == "UP"
    {
      reviewer_id: current_user.id,
      product_id: @product.id,
      rating: rating,
      comment: params[:comment],
      helpful_votes: 0
    }
  end
end
