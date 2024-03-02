class User::AllergensController < UserApplicationController
  def search
    allergens = Allergen.all
    matched_allergens = allergens.select { |allergen| allergen.name.downcase.include?(params[:term].downcase) }.first(10)
    render json: matched_allergens.map { |allergen| { label: allergen.name, value: allergen.off_id } }, status: :ok
  end
end
