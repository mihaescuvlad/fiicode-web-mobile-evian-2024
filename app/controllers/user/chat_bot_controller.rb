class User::ChatBotController < UserApplicationController
  before_action :authenticate_user!

  before_action :ensure_chat_initialized

  def send_message
    response = ChatBot.send_message(params[:message], session[:thread_id])
    message = { role: 'assistant', message: response }
    render json: message
  end

  private

  def ensure_chat_initialized
    if session[:thread_id].blank?
      reset_chat
    end
  end

end