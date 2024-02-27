class User::AllergensController < UserApplicationController
  

  def search
    allergens = Rails.cache.read('allergens_list') || []
    matched_allergens = allergens.select { |allergen| allergen.downcase.include?(params[:term].downcase) }.sort.first(10)
    render json: matched_allergens.map { |allergen| { label: allergen, value: allergen } }
  end

  def add_allergen
    current_user.allergens << params[:allergen]
    current_user.save
    render json: { status: 'ok' }
  end

  def remove_allergen
    current_user.allergens.delete(params[:allergen])
    current_user.save
    render json: { status: 'ok' }
  end

end
