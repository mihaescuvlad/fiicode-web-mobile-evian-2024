class Admin::FeedbackMessagesController < AdminApplicationController
  before_action :authenticate_user!

  def index
    params[:page] ||= 1
    @total_pages = FeedbackMessage.where(read: false).count / 10 + 1
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
