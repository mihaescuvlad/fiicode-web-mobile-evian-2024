class User::ProductsController < UserApplicationController
  before_action :authenticate_user!, only: %i[ new edit create update destroy ]
  before_action :set_product, only: %i[ show edit update destroy ]

  
  FATS = %i[ fat saturated_fat polysaturated_fat monosaturated_fat trans_fat ].freeze
  CARBOHYDRATES = %i[ carbohydrates fiber sugar ].freeze
  VITAMINS_MINERALS = %i[ vitamin_A vitamin_C calcium ].freeze
  ESSENTIAL_NUTRIENTS = %i[ protein sodium iron ].freeze

  def index
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
    @weight_units_strings = Measurement.pluck(:_id, :unit).to_h
    @weight_units = @product.weight_units.map { |measurement_id| Measurement.find(measurement_id).unit }

    @product_allergens = Allergen.where(:off_id.in => @product.allergens || [])
    @reviews = Review.where(product_id: @product.id)
    @current_user_review = @reviews.find_by(reviewer_id: current_user.id) rescue nil
    @product_submitter = User.find(@product.submitted_by)
    @user_allergic_to_product = current_user.present? && current_user.allergens_ids.present? && @product.allergens.present? && current_user.allergens_ids.any? { |allergen| @product.allergens.include?(allergen) }
  end

  def new
    @product = Product.new
  end

  def edit
  end

  def create
    @product = Product.new(product_params)
    @product.submitted_by = current_user.id

    @product.allergens = params[:product][:allergens].presence || []

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
    @product = Product.new(product_params)

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

  def search
    @products = Product.where(name: /#{params[:term]}/i)
    render json: @products.map { |product| { label: product.name, value: product.id } }
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:brand, :name, :price, :weight, :weight_units, :servings, :allergens, :calories, :fat, :saturated_fat, :polysaturated_fat, :monosaturated_fat, :trans_fat, :carbohydrates, :fiber, :sugar, :protein, :sodium, :vitamin_A, :vitamin_C, :calcium, :iron)
    end
end
