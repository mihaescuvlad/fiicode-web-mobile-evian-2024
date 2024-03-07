class Admin::ProductsController < AdminApplicationController
    before_action :authenticate_user!
    before_action :set_product, only: %i[show approve reject]

    def index
    end

    def show
        @weight_units_strings = Measurement.pluck(:_id, :unit).to_h
        @weight_units = @product.weight_units.map { |measurement_id| Measurement.find(measurement_id).unit }

        @product_allergens = Allergen.where(:off_id.in => @product.allergens || [])
        @product_submitter = User.find(@product.submitted_by)
    end

    def approve
        @product.update_attribute(:status, :APPROVED)
        redirect_to admin_submissions_path, notice: 'Product approved'
    end

    def reject
        @product.update_attribute(:status, :REJECTED)
        redirect_to admin_submissions_path, notice: 'Product rejected'
    end

    private

    def set_product
        @product = Product.find(params[:id])
    end
end