class User::AllergensController < UserApplicationController
  def search
    allergens = Rails.cache.read('allergens_list') || []
    matched_allergens = allergens.select { |allergen| allergen.dig(:name).downcase.include?(params[:term].downcase) }.first(10)
    render json: matched_allergens.map { |allergen| { label: allergen.dig(:name), value: allergen.dig(:id) } }
  end
end
