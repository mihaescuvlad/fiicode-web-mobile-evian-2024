class User::NotificationsController < UserApplicationController
  before_action :authenticate_user!

  def destroy
    @notification = Notification.find(params[:id])
    @notification.destroy!
    head :no_content
  end
end