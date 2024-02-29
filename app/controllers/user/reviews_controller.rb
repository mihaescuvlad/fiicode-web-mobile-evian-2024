class User::ReviewsController < UserApplicationController
  before_action :authenticate_user!
  before_action :set_product
  before_action :set_review, only: %i[edit update destroy]
  before_action :review_params, only: %i[edit update destroy]

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
      respond_to do |format|
        if review.update(review_params)
          format.html { redirect_to user_product_path(@review.product_id), notice: "Review was successfully updated." }
          format.json { render :show, status: :ok, location: @review }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @review.errors, status: :unprocessable_entity }
        end
      end
    rescue
      render json: { message: "Something went wrong with updating your review. Please take a break, read a book and try again later." }, status: :bad_request and return
    end
  end

  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_url, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_product
    @product ||= Product.find(params[:product_id])
  end

  def set_review
    @review ||= Review.find_by(id: params[:id], product_id: @product.id, reviewer_id: current_user.id)
  end

  def review_params
    raise "You have to like or dislike a product." if params[:rating] == nil
    rating = params[:rating] == "like" ? true : false

    {
      reviewer_id: current_user.id,
      product_id: @product.id,
      rating: rating,
      comment: params[:comment],
      helpful_votes: 0
    }
  end
end
