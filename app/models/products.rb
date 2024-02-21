class Products
  include Mongoid::Document
  include Mongoid::Created::Timestamps
  field :ean, type: String, as:_id, required: true

  field :brand, type: String, required: true
  field :name, type: String, required: true

  field :price, type: Float, required: true
  field :weight, type: Float, required: true
  field :weight_units, type: Array, required: true
  field :servings, type: Integer, required: true
  field :allergens, type: Array
  field :calories, type: Float, required: true
  field :fat, type: Float, required: true
  field :saturated_fat, type: Float
  field :polysaturated_fat, type: Float
  field :monosaturated_fat, type: Float
  field :carbohydrates, type: Float, required: true
  field :fiber, type: Float
  field :sugar, type: Float
  field :protein, type: Float, required: true
  field :sodium, type: Float
  field :vitamin_A, type: Float
  field :vitamin_C, type: Float
  field :calcium, type: Float
  field :iron, type: Float


  field :submitted_by, type: BSON::ObjectId, required: true
  field :approved, type: Boolean, required: true
  field :rating, type: Float, required: true
end
