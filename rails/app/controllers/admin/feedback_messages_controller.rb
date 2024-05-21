class Admin::FeedbackMessagesController < AdminApplicationController
  before_action :authenticate_user!

  def index
    params[:page] ||= 1
    total_items = FeedbackMessage.where(read: false).count
    items_per_page = 10
    total_pages = (total_items.to_f / items_per_page).ceil
    @total_pages = total_pages > 0 ? total_pages : 1

    @feedback_messages = FeedbackMessage.where(read: false).order(created_at: :asc).skip((params[:page].to_i - 1) * 10).limit(10)
  end

  def mark_as_read
    @feedback_message = FeedbackMessage.find(params[:id])
    @feedback_message.update_attribute(:read, true)
    redirect_to admin_feedback_messages_path, notice: 'Feedback message marked as read'
  end

  def show
  end
end
