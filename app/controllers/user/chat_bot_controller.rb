class User::ChatBotController < UserApplicationController
  before_action :authenticate_user!

  before_action :ensure_chat_initialized

  def send_message
    response = ChatBot.send_message(params[:message], session[:thread_id])
    message = { role: 'assistant', message: response }
    render json: message
  end
end