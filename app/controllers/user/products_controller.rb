class User::ProductsController < UserApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: %i[ show edit update destroy ]

  def index
    @products = Product.all
  end

  def show
    puts params.inspect

    @product = Product.find(params[:id])
    @allergen_names = Allergen.pluck(:_id, :name).to_h
    @weight_units_strings = Measurement.pluck(:_id, :unit).to_h
    @weight_units = @product.weight_units.map { |measurement_id| Measurement.find(measurement_id).unit }
    @user_names = User.pluck(:_id, :name).to_h
    @reviews = Review.where(product_id: @product.id)
  end

  def new
    @product = Product.new
  end

  def edit
  end

  def create
    @product = Product.new(product_params)
    @product.rating = 0
    @product.approved = false
    @product.submitted_by = current_user.id

    @product.allergens ||= []

    # Default values if `nil`: "1 g", "100 g"
    @product.weight_units ||= [
      BSON::ObjectId('65d320c04bbf6989c52c9571'),
      BSON::ObjectId('65d320ca4bbf6989c52c9572'),
    ]

    # Add the "1 serving" and "1 container" mandatory weight units
    @product.weight_units.append(
      BSON::ObjectId('65d320e64bbf6989c52c9575'),
      BSON::ObjectId('65d320f74bbf6989c52c9576')
    )

    puts @product.inspect
  
    respond_to do |format|
      if @product.save
        format.html { redirect_to user_product_path(@product.id), notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to user_product_path(@product.id), notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
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
      @product = Product.find(params[:id])
    end

    def product_params
      puts params.inspect
      params.require(:product).permit(:brand, :name, :price, :weight, :weight_units, :servings, :allergens, :calories, :fat, :saturated_fat, :polysaturated_fat, :monosaturated_fat, :trans_fat, :carbohydrates, :fiber, :sugar, :protein, :sodium, :vitamin_A, :vitamin_C, :calcium, :iron)
    end
end
