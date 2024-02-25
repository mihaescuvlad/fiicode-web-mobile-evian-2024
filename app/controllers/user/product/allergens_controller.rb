class User::Product::AllergensController < UserApplicationController
  before_action :set_allergen, only: %i[ show ]

  def index
    @allergens = Allergen.all
  end

  def show
  end

  private
    def set_allergen
      @allergen = Allergen.find(params[:id])
    end
end
