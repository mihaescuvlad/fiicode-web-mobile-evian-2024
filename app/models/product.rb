class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  APPROVED_STATUSES = %i[pending approved rejected]

  field :ean, type: String, as: :id
  field :brand, type: String
  field :name, type: String
  field :price, type: Float
  field :weight, type: Float
  field :weight_units, type: Array, default: [  BSON::ObjectId('65d320c04bbf6989c52c9571'),
                                                BSON::ObjectId('65d320ca4bbf6989c52c9572'),
                                                BSON::ObjectId('65d320f74bbf6989c52c9576')]
  field :allergens, type: Array
  field :calories, type: Float
  field :fat, type: Float
  field :saturated_fat, type: Float
  field :polysaturated_fat, type: Float
  field :monosaturated_fat, type: Float
  field :trans_fat, type: Float
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
  field :status, type: Symbol, default: :pending
  field :rating, type: Float, default: 0.0

  def self.from_open_food_facts(ean)
    OpenFoodFacts.product(ean)
  end

end
