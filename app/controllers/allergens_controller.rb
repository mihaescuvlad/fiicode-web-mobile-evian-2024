class AllergensController < ApplicationController
  before_action :set_allergen, only: %i[ show ]

  # GET /allergens
  def index
    @allergens = Allergen.all
  end

  # Get /allergens/:id
  def show
  end

  private
    def set_allergen
      @allergen = Allergen.find(params[:id])
    end
end
