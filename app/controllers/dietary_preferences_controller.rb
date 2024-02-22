class DietaryPreferencesController < ApplicationController
  before_action :set_dietary_preference, only: %i[ show ]

  # GET /dietary_preferences
  def index
    @dietary_preferences = DietaryPreference.all
  end

  # GET /dietary_preferences/:id
  def show
  end

  private
    def set_dietary_preference
      @dietary_preference = DietaryPreference.find(params[:id])
    end
end
