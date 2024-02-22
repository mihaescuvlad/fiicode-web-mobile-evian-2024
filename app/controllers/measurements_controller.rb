class MeasurementsController < ApplicationController
  before_action :set_measurement, only: %i[ show ]

  # GET /measurements
  def index
    @measurements = Measurement.all
    render json: @measurements
  end

  # GET /measurements/:id
  def show
  end

  private
    def set_measurement
      @measurement = Measurement.find(params[:id])
    end
end
