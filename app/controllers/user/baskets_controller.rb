class User::BasketsController < UserApplicationController
  def show
    params[:page] ||= 1
    recommendation_products = RecommendationsApi.paginated_products(current_user, params[:page]) || {}
    @products = Product.where(:_id.in => recommendation_products["products"])
    basket_product_ids = current_user.favorites
    @basket_products = Product.where(:_id.in => basket_product_ids)
    @total_pages = recommendation_products["total_pages"]
  end
end
