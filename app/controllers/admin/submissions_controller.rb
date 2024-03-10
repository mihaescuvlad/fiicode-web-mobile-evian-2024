class Admin::SubmissionsController < AdminApplicationController

  before_action :authenticate_user!

  def index
    @submissions = Product.where(status: :PENDING)
  end
end