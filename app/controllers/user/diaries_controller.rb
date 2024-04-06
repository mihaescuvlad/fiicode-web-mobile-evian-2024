class User::DiariesController < UserApplicationController
  before_action :authenticate_user!

  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    start_of_day = @date.in_time_zone.beginning_of_day
    end_of_day = @date.in_time_zone.end_of_day
    
    date_key = start_of_day.strftime('%Y-%m-%d')
    @products = Diary
                  .where(user_id: current_user.id)
                  .and("products.#{date_key}".to_sym.exists => true)
                  .first
                  .try(:products)
                  .try(:[], date_key) || []
    @products = @products.map do |product|
      Product.find(product["product_id"])
    end
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
