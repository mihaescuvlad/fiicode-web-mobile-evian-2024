class User::SubmissionsController < UserApplicationController

    before_action :authenticate_user!

    def index
        @submitted_products = Product.where(submitted_by: current_user.id)
    end

end