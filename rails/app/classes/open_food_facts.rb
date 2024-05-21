require 'http'

class OpenFoodFacts
  @@API = 'https://world.openfoodfacts.org/api/v3'.freeze

  def self.product(ean)
    begin
      product = get(@@API, "/product/#{ean}")["product"]
    rescue
      return nil
    end

    return nil if product.nil? || product.empty?
    map_product_to_model(product)
  end

  def self.search_by_name(name)
    response = get("https://world.openfoodfacts.org//cgi/search.pl", "?search_terms=#{name}&json=1")
    return nil if response["products"][0].nil?

    product(response["products"][0]["_id"])
  end

  def self.search_by_name_list(name, limit, page)
    response = get("https://world.openfoodfacts.org//cgi/search.pl", "?search_terms=#{name}&json=1&page=#{page}&page_size=#{limit}")
    return nil if response["products"].nil?

    { products: response["products"].map { |product| map_product_to_model(product) }, total: (response["count"].to_i / limit).floor }
  end

  def self.get(api, endpoint)
    res = HTTP.get(api + endpoint)
    unless res.status.success?
      return nil
    end

    JSON.parse res.body
  end

  private
  
  def self.map_product_to_model(product)
    allergens = product[:allergens_tags.to_s].select { |allergen| allergen.start_with?('en:') } rescue []
    ingredients = product[:ingredients_tags.to_s].select { |ingredient| ingredient.start_with?('en:') } rescue []
    vegan = !product[:ingredients_analysis_tags.to_s].any? { |tag| tag == "en:non-vegan" } rescue true
    vegetarian = !product[:ingredients_analysis_tags.to_s].any? { |tag| tag == "en:non-vegetarian" } rescue true
    
    Product.new(
      ean: product[:_id.to_s],
      brand: product[:brands.to_s] != '' ? product[:brands.to_s] : 'Unknown',
      name: product[:product_name.to_s] != '' ? product[:product_name.to_s] : 'Unknown',
      nutriscore: product[:nutrition_grades.to_s],
      allergens: allergens,
      ingredients: ingredients,
      weight: product[:product_quantity.to_s],
      calories: product[:nutriments.to_s]["energy-kcal_100g"]&.to_f&.round(2),
      protein: product[:nutriments.to_s]["proteins_100g"]&.to_f&.round(2),
      fat: product[:nutriments.to_s]["fat_100g"]&.to_f&.round(2),
      saturated_fat: product[:nutriments.to_s]["saturated-fat_100g"]&.to_f&.round(2),
      carbohydrates: product[:nutriments.to_s]["carbohydrates_100g"]&.to_f&.round(2),
      fiber: product[:nutriments.to_s]["fiber_100g"]&.to_f&.round(2),
      sugar: product[:nutriments.to_s]["sugars_100g"]&.to_f&.round(2),
      sodium: product[:nutriments.to_s]["sodium_100g"]&.to_f&.round(2),
      vegan: vegan,
      vegetarian: vegetarian,
      image_url: product[:image_url.to_s]
    )
  end

end
