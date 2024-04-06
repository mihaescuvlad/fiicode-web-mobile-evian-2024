class User::ProductsController < UserApplicationController
  before_action :authenticate_user!, only: %i[ new edit create update destroy ]
  before_action :set_product, only: %i[ show edit update destroy add_to_favorites remove_from_favorites ]
  skip_before_action :verify_authenticity_token, only: %i[ create update ]

  FATS = %i[ fat saturated_fat ].freeze
  CARBOHYDRATES = %i[ carbohydrates fiber sugar ].freeze
  VITAMINS_MINERALS = %i[ vitamin_A vitamin_C calcium ].freeze
  ESSENTIAL_NUTRIENTS = %i[ protein sodium iron ].freeze

  def index
    params[:page] ||= 1
    @top_products = ProductsRecommendation.filter_products_with_aggregation(current_user, 9, (params[:page].to_i - 1) * 9) rescue []
    @total_pages = (Product.where(status: :APPROVED).count.to_f / 9).ceil
  end

  def show
    if @product.status == :PENDING && (current_user.blank? || @product.submitted_by != current_user)
      redirect_to user_products_path and return
    end

    @allergen_names = Allergen.pluck(:_id, :name).to_h

    @product_allergens = Allergen.where(:off_id.in => @product.allergens || [])
    @reviews = Review.where(product_id: @product.id)
    @current_user_review = @reviews.find_by(reviewer_id: current_user.id) rescue nil
    @product_submitter = User.find(@product.submitted_by)
    @user_allergic_to_product = current_user.present? && current_user.allergens_ids.present? && @product.allergens.present? && current_user.allergens_ids.any? { |allergen| @product.allergens.include?(allergen) }

    ensure_chat_initialized
    ChatBot.send_context(@product, session[:thread_id])
  end

  def new
    @product = Product.new
    @product.ean = params[:ean]
    @matching_product = OpenFoodFacts.product(params[:ean])

    if @matching_product.nil?
      respond_to do |format|
        format.json { render json: { message: "The product does not exists." }, status: :unprocessable_entity }
        format.html { redirect_to create_product_user_products_path, notice: "The product does not exists." }
      end

      return
    end

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
        redirect_to products_selection_user_products_path(name: params[:name], page: 1), method: :get and return
      end
      redirect_to create_product_user_products_path and return if @product.nil?
      matching_product = Product.find_by(ean: @product.ean) rescue nil
      redirect_to user_product_path(matching_product) and return if matching_product.present? rescue nil
      if @product.present?
        redirect_to new_user_product_path(ean: @product.ean) and return
      else
        redirect_to new_user_product_path(ean: params[:ean]), notice: "Product not found in Open Food Facts database. Please fill in the details manually."
      end
    end
  end

  def products_selection
    response = OpenFoodFacts.search_by_name_list(params[:name], 3, params[:page].to_i)
    @products = response[:products]
    @total_pages = response[:total]
    if @products.blank?
      redirect_to create_product_user_products_path and return
    end
  end

  def create
    new_product_params = product_params
    new_product_params[:ean] = params[:ean]
    new_product_params[:nutriscore] = params[:nutriscore]
    new_product_params[:vegan] = params[:vegan]
    new_product_params[:vegetarian] = params[:vegetarian]
    new_product_params[:allergens] = params[:allergens].presence || []
    new_product_params[:ingredients] = params[:ingredients].split(' ').presence || []
    new_product_params.each { |key, value| new_product_params[key] = value.strip.gsub(/[\n\r]+/, '') if value.is_a?(String) }
    @product = Product.new(new_product_params)
    @product.submitted_by = current_user.id
    
    @matching_product = OpenFoodFacts.product(params[:ean])
    @product.status = :APPROVED if perfect_match?(@product, @matching_product) rescue false

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
    new_product_params[:nutriscore] = params[:nutriscore]
    new_product_params[:vegan] = params[:vegan]
    new_product_params[:vegetarian] = params[:vegetarian]
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
    products = Product.where(name: /#{params[:term]}/i, status: :APPROVED).limit(5)
    products = products.map { |product| { label: product.name, value: "/products/" + product.id.to_s } }
    products << { label: "Can't find what you're searching for? Explore more options here!", value: "/search?query=#{params[:term]}" }
    render json: products
  end

  def search_by_ean
    @product = Product.find_by(ean: params[:ean]) rescue nil
    if @product.present?
      render json: { url: user_product_path(@product.id) } and return
    else
      render json: { url: new_user_product_path(ean: params[:ean]) } and return
    end
  end

  def add_to_favorites
    current_user.favorites << @product.id
    current_user.save!
    render json: { message: 'Product added to favorites' }, status: :ok
  end

  def remove_from_favorites
    current_user.favorites.delete(@product.id)
    current_user.save!
    render json: { message: 'Product removed from favorites' }, status: :ok
  end
  
private

  def perfect_match?(product, matching_product)
    product.name == matching_product.name && product.brand == matching_product.brand && product.weight == matching_product.weight &&
      (product.allergens || []).sort == (matching_product.allergens || []).sort && (product.calories || 0) == (matching_product.calories || 0) && (product.fat || 0) == (matching_product.fat || 0) &&
        (product.saturated_fat || 0) == (matching_product.saturated_fat || 0) && (product.carbohydrates || 0) == (matching_product.carbohydrates || 0) && (product.fiber || 0) == (matching_product.fiber || 0) &&
          (product.sugar || 0) == (matching_product.sugar || 0) && (product.protein || 0) == (matching_product.protein || 0) && (product.sodium || 0) == (matching_product.sodium || 0)

  end

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:brand, :name, :price, :weight, :calories, :fat, :saturated_fat, :carbohydrates, :fiber, :sugar, :protein, :sodium, :vitamin_A, :vitamin_C, :calcium, :iron, allergens: [], ingredients: [])
  end
end
