class User::ProductsController < UserApplicationController
  before_action :authenticate_user!, only: %i[ new edit create update destroy ]
  before_action :set_product, only: %i[ show edit update destroy ]
  skip_before_action :verify_authenticity_token, only: %i[ create update ]

  FATS = %i[ fat saturated_fat polysaturated_fat monosaturated_fat trans_fat ].freeze
  CARBOHYDRATES = %i[ carbohydrates fiber sugar ].freeze
  VITAMINS_MINERALS = %i[ vitamin_A vitamin_C calcium ].freeze
  ESSENTIAL_NUTRIENTS = %i[ protein sodium iron ].freeze

  def index
    @products = Product.all
    @filtered_products = filter_products(@products)
    @top_products = @filtered_products.take(9)
  end

  def show
    if @product.status == :PENDING && (current_user.blank? || @product.submitted_by != current_user)
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
    @product.ean = params[:ean]
    @matching_product = OpenFoodFacts.product(params[:ean])
    @product_allergens = Allergen.where(:off_id.in => @matching_product.allergens).to_a
  end

  def edit
    @product_allergens = Allergen.where(:off_id.in => @product.allergens).to_a
  end

  def create_product
    if request.post?
      if params[:ean].present?
        @product = OpenFoodFacts.product(params[:ean])
      else
        @product = OpenFoodFacts.search_by_name(params[:name])
      end
      redirect_to user_product_path(@product.ean) and return if Product.find_by(ean: @product.ean).present? rescue nil
      if @product.present?
        redirect_to new_user_product_path(ean: @product.ean) and return
      else
        redirect_to new_user_product_path(ean: params[:ean]), notice: "Product not found in Open Food Facts database. Please fill in the details manually."
      end
    end
  end

  def create
    new_product_params = product_params
    new_product_params[:ean] = params[:ean]
    new_product_params[:allergens] = params[:allergens].presence || []
    new_product_params.each { |key, value| new_product_params[key] = value.strip.gsub(/[\n\r]+/, '') if value.is_a?(String) }
    @product = Product.new(new_product_params)
    @product.submitted_by = current_user.id

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
    new_product_params = product_params
    new_product_params[:ean] = params[:ean]
    new_product_params[:allergens] = params[:allergens].presence || []
    new_product_params.each { |key, value| new_product_params[key] = value.strip.gsub(/[\n\r]+/, '') if value.is_a?(String) }

    respond_to do |format|
      if @product.update(new_product_params)
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

  def search_by_ean
    @product = Product.find_by(ean: params[:ean]) rescue nil
    if @product.present?
      render json: { url: user_product_path(@product.id) } and return
    else
      render json: { url: new_user_product_path(ean: params[:ean]) } and return
    end
  end

  private
    def filter_products(products)
      products.sort_by do |product|
        reviews = Review.where(product_id: product.id)
        total_reviews = reviews.count

        positive_review_percentage = total_reviews.zero? ? -1 : (product.rating.to_f / total_reviews * 100)
        allergen_penalty = current_user.present? && current_user.allergens_ids.present? && (current_user.allergens_ids & product.allergens).any? ? 35 : 0
        overall_score = (positive_review_percentage - allergen_penalty) * total_reviews

        -overall_score
      end
    end

    def set_product
      @product = Product.find(params[:id])
    end

  def product_params
    params.require(:product).permit(:brand, :name, :price, :weight, :weight_units, :servings, :calories, :fat, :saturated_fat, :polysaturated_fat, :monosaturated_fat, :trans_fat, :carbohydrates, :fiber, :sugar, :protein, :sodium, :vitamin_A, :vitamin_C, :calcium, :iron, allergens: [])
  end
end
