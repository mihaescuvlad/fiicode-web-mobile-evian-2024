class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  field :ean, type: String, as: :_id

  field :brand, type: String
  field :name, type: String

  field :price, type: Float
  field :weight, type: Float
  field :weight_units, type: Array
  field :serving_quantity, type: Integer

  def servings
    (weight / serving_quantity).floor
  end

  field :allergens, type: Array

  field :calories, type: Float

  field :fat, type: Float
  field :saturated_fat, type: Float
  field :polysaturated_fat, type: Float
  field :monosaturated_fat, type: Float

  field :carbohydrates, type: Float
  field :fiber, type: Float
  field :sugar, type: Float

  field :protein, type: Float

  field :sodium, type: Float
  field :vitamin_A, type: Float
  field :vitamin_C, type: Float
  field :calcium, type: Float
  field :iron, type: Float

  field :submitted_by, type: BSON::ObjectId
  field :approved, type: Boolean
  field :rating, type: Float

  def self.from_open_food_facts(ean)
    OpenFoodFacts.product(ean)
  end

end
