require "http"

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

  def self.fromOpenFoodFacts(ean)
    endpoint = "https://world.openfoodfacts.org/api/v3/product/#{ean}".freeze
    response = HTTP.get(endpoint)
    unless response.status.success?
      return nil
    end

    data = response.parse[:product.to_s]

    allergens = data[:allergens_tags.to_s].map { |a| a.gsub("en:", "") }
    allergens.map! { |a| Allergen.where(off_counterpart: a).first }.filter! { |a| not a.nil? }

    Product.new(
      ean: ean,
      brand: data[:brands.to_s],
      name: data[:product_name.to_s],
      allergens: allergens.map { |a| a._id },
      weight: data[:product_quantity.to_s],
      serving_quantity: data[:serving_quantity.to_s],
      calories: data[:nutriments.to_s]["energy-kcal_100g"],
      protein: data[:nutriments.to_s]["proteins_100g"],
      fat: data[:nutriments.to_s]["fat_100g"],
      saturated_fat: data[:nutriments.to_s]["saturated_fat_100g"],
      carbohydrates: data[:nutriments.to_s]["carbohydrates_100g"],
      fiber: data[:nutriments.to_s]["fiber_100g"],
      sugar: data[:nutriments.to_s]["sugars_100g"],
      sodium: data[:nutriments.to_s]["sodium_100g"],
    )
  end

end
