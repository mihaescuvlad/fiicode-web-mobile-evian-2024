class Diary
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user_id, type: String
  field :products, type: Hash, default: -> { Hash.new { |hash, key| hash[key] = [] } }  

  def add_product(product_id, date, quantity)
    self.products[date.strftime('%Y-%m-%d')] << { product_id: product_id, quantity: quantity }
  end

end