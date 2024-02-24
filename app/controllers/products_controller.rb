class ProductsController < ProductApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]

  def index
    @products = Product.all
    # @allergen_names = Allergen.pluck(:_id, :name).to_h
    # @weight_units_strings = Measurement.pluck(:_id, :unit).to_h
    # @weight_units = @product.weight_units.map { |measurement_id| Measurement.find(measurement_id).unit }
    # @user_names = User.pluck(:_id, :name).to_h
  end

  def show
    @product = Product.find(params[:id])
    @allergen_names = Allergen.pluck(:_id, :name).to_h
    @weight_units_strings = Measurement.pluck(:_id, :unit).to_h
    @weight_units = @product.weight_units.map { |measurement_id| Measurement.find(measurement_id).unit }
    @user_names = User.pluck(:_id, :name).to_h
  end

  def new
    @product = Product.new
  end

  def edit
  end

  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to product_url(@product), notice: "Product was successfully created." }
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
        format.html { redirect_to product_url(@product), notice: "Product was successfully updated." }
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
      #params.fetch(:product, {})
      params.require(:product).permit(:ean, :brand, :name, :price, :weight, :weight_units, :servings, :allergens, :calories, :fat, :saturated_fat, :polysaturated_fat, :monosaturated_fat, :trans_fat, :carbohydrates, :fiber, :sugar, :protein, :sodium, :vitamin_A, :vitamin_C, :calcium, :iron, :submitted_by, :approved, :rating)
    end
end
