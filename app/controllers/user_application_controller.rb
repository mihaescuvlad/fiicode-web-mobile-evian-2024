class UserApplicationController < ApplicationController
  layout 'user_application'
  # after_action :set_cache_headers

  def current_login
    return nil if session[:login_id].blank?
    @current_login ||= Login.find(session[:login_id]["$oid"]) rescue nil
  end

  def current_user
    current_login.user rescue nil
  end

  def reset_chat
    session[:thread_id] = ChatBot.create_thread
  end

  def ensure_chat_initialized
    if session[:thread_id].blank?
      reset_chat
    end
  end

  helper_method :current_user

  private

  def set_cache_headers
    response.headers['Cache-Control'] = 'public, max-age=31536000'
  end

end