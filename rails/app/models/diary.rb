class Diary
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user_id, type: String
  field :products, type: Hash, default: -> { Hash.new { |hash, key| hash[key] = [] } }  

  def add_product(product_id, date, quantity)
    date = date.strftime('%Y-%m-%d') if date.is_a?(Date)
    self.products[date] << { product_id: product_id, quantity: quantity }
  end

  def modify_product(product_id, date, quantity)
    date = date.strftime('%Y-%m-%d') if date.is_a?(Date)
    self.products[date].each do |product|
      if product["product_id"] == product_id
        product["quantity"] = quantity
      end
    end
  end

  def remove_product(product_id, date)
    date = date.strftime('%Y-%m-%d') if date.is_a?(Date)
    self.products[date].delete_if { |product| product["product_id"] == product_id }
  end

end