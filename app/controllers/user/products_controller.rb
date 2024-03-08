class User::ProductsController < UserApplicationController
  before_action :authenticate_user!, only: %i[ new edit create update destroy ]
  before_action :set_product, only: %i[ show edit update destroy ]

  
  FATS = %i[ fat saturated_fat polysaturated_fat monosaturated_fat trans_fat ].freeze
  CARBOHYDRATES = %i[ carbohydrates fiber sugar ].freeze
  VITAMINS_MINERALS = %i[ vitamin_A vitamin_C calcium ].freeze
  ESSENTIAL_NUTRIENTS = %i[ protein sodium iron ].freeze

  def index
    @products = Product.all
    @filtered_products = filter_products(@products)
    @top_products = @filtered_products.take(9);
  end

  def show
    if @product.status == :PENDING && (current_user.blank? || @product.submitted_by != current_user.id)
      redirect_to user_products_path and return
    end

    @allergen_names = Allergen.pluck(:_id, :name).to_h
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
    @product_allergens = Allergen.where(:off_id.in => @product.allergens).to_a
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
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to user_submissions_path }
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
    def filter_products(products)
      products.sort_by do |product|
        reviews = Review.where(product_id: product.id)
        total_reviews = reviews.count

        positive_review_percentage = total_reviews.zero? ? -1 : (product.rating.to_f / total_reviews * 100)

        if current_user.allergens.any? { |allergen| product.allergens }
          corrected_percentage = positive_review_percentage - 35
          positive_review_percentage = [corrected_percentage, -1].max
        end

        -positive_review_percentage
      end
    end

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:brand, :name, :price, :weight, :weight_units, :servings, :calories, :fat, :saturated_fat, :polysaturated_fat, :monosaturated_fat, :trans_fat, :carbohydrates, :fiber, :sugar, :protein, :sodium, :vitamin_A, :vitamin_C, :calcium, :iron, allergens: [])
    end
end
