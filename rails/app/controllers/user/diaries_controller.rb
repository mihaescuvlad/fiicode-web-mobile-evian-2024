class User::DiariesController < UserApplicationController
  before_action :authenticate_user!

  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    start_of_day = @date.in_time_zone.beginning_of_day
    end_of_day = @date.in_time_zone.end_of_day
    
    date_key = start_of_day.strftime('%Y-%m-%d')
    @diary_products = Diary
                  .where(user_id: current_user.id)
                  .and("products.#{date_key}".to_sym.exists => true)
                  .first
                  .try(:products)
                  .try(:[], date_key) || []
    @products = @diary_products.map do |product|
      current_product = Product.find(product["product_id"])
      product['fats'] = (current_product.fat * product["quantity"] / 100).round(2)
      product['carbs'] = (current_product.carbohydrates * product["quantity"] / 100).round(2)
      product['proteins'] = (current_product.protein * product["quantity"] / 100).round(2)
      product['calories'] = (current_product.calories * product["quantity"] / 100)
      current_product
    end

    @total_calories = @diary_products.sum { |product| product['calories'] }
    @total_fats = @diary_products.sum { |product| product['fats'] }
    @total_carbs = @diary_products.sum { |product| product['carbs'] }
    @total_proteins = @diary_products.sum { |product| product['proteins'] }

    @data = current_user.get_nutritional_stats_last_30_days
  end

  def add_to_user_diary
    product_id = params[:product_id]
    date = Date.parse(params[:date])
   date_key = date.strftime('%Y-%m-%d')

    diary = Diary.where(user_id: current_user.id).first_or_create
    diary.add_product(product_id, date_key, params[:quantity].to_i)
    diary.save
  end

  def remove_from_user_diary
    product_id = params[:product_id]
    date = Date.parse(params[:date])
    date_key = date.strftime('%Y-%m-%d')

    diary = Diary.where(user_id: current_user.id).first
    diary.remove_product(product_id, date_key)
    diary.save
  end

  def modify_user_diary
    product_id = params[:product_id]
    date = Date.parse(params[:date])
    date_key = date.strftime('%Y-%m-%d')

    diary = Diary.where(user_id: current_user.id).first
    diary.modify_product(product_id, date_key, params[:quantity].to_i)
    diary.save
  end

end
