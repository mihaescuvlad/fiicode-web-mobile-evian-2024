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
  end

  def add_to_user_diary
    product_id = params[:product_id]
    date = Date.parse(params[:date])
    date_key = date.strftime('%Y-%m-%d')

    diary = Diary.where(user_id: current_user.id).first_or_create
    diary.add_product(product_id, date, params[:quantity].to_i)
    diary.save
  end

end
