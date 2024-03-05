require 'http'

module OpenFoodFacts
  @@API = 'https://world.openfoodfacts.org/api/v3'.freeze

  def self.product(ean)
    begin
      product = get("/product/#{ean}")[:product.to_s]
    rescue
      return nil
    end

    allergens = product[:allergens_tags.to_s].map { |a| a.gsub("en:", "") }
    allergens.map! { |a| Allergen.where(off_counterpart: a).first }.filter! { |a| not a.nil? }

    Product.new(
      ean: ean,
      brand: product[:brands.to_s],
      name: product[:product_name.to_s],
      allergens: allergens.map { |a| a._id },
      weight: product[:product_quantity.to_s],
      serving_quantity: product[:serving_quantity.to_s],
      calories: product[:nutriments.to_s]["energy-kcal_100g"],
      protein: product[:nutriments.to_s]["proteins_100g"],
      fat: product[:nutriments.to_s]["fat_100g"],
      saturated_fat: product[:nutriments.to_s]["saturated_fat_100g"],
      carbohydrates: product[:nutriments.to_s]["carbohydrates_100g"],
      fiber: product[:nutriments.to_s]["fiber_100g"],
      sugar: product[:nutriments.to_s]["sugars_100g"],
      sodium: product[:nutriments.to_s]["sodium_100g"],
    )
  end

  def self.get(endpoint)
    res = HTTP.get(@@API + endpoint)
    unless res.status.success?
      return nil
    end

    JSON.parse res.body
  end
end
