class User::ChatBotController < UserApplicationController
  def send_message
    response = ChatBot.send_message(params[:message], session[:thread_id])
    message = { role: 'assistant', message: response }
    render json: message
  end
end