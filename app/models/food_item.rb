class FoodItem
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :description, type: String
  field :carbohydrates, type: Integer
  field :sugars, type: Integer
  field :fat, type: Integer
  field :protein, type: Integer
end
