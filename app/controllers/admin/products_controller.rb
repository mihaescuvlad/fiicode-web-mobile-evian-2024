class Admin::ProductsController < AdminApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: %i[show approve reject]

  def index
  end

  def show
    @product_allergens = Allergen.where(:off_id.in => @product.allergens || []).to_a
    @matching_product = OpenFoodFacts.product(@product.ean)
    @product_matching_allergens = Allergen.where(:off_id.in => @matching_product.allergens || []).to_a
    @allergens_mismatch = @product_allergens.map(&:name) != @product_matching_allergens.map(&:name)
  end

  def approve
    @product.update_attribute(:status, :APPROVED)
    redirect_to admin_submissions_path, notice: 'Product approved'
  end

  def reject
    @product.update_attribute(:status, :REJECTED)
    redirect_to admin_submissions_path, notice: 'Product rejected'
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end
end