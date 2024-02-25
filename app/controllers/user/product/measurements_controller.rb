class User::Product::MeasurementsController < UserApplicationController
  before_action :set_measurement, only: %i[ show ]

  def index
    @measurements = Measurement.all
    render json: @measurements
  end

  def show
  end

  private
    def set_measurement
      @measurement = Measurement.find(params[:id])
    end
end
