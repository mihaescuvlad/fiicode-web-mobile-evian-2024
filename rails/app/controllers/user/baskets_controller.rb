class User::BasketsController < UserApplicationController
  before_action :authenticate_user!

  def show
    params[:favorites_page] ||= 1
    recommendation_products = RecommendationsApi.paginated_products(current_user, 1, 3) || {}
    @products = Product.where(:_id.in => recommendation_products["products"])
    
    basket_product_ids = current_user.favorites
    favorite_total_pages = (basket_product_ids.count.to_f / 9).ceil
    if params[:favorites_page].to_i > favorite_total_pages
      params[:favorites_page] = favorite_total_pages == 0 ? 1 : favorite_total_pages
    end

    @basket_products = Product.where(:_id.in => basket_product_ids).skip((params[:favorites_page].to_i - 1) * 9).limit(9)
    @basket_total_pages = favorite_total_pages || 1
  end
end
