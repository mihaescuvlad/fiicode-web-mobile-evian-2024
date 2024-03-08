class ApplicationController < ActionController::Base
  layout 'user_application'

  before_action :write_notice_to_header

  def authenticate_user!
    if session[:login_id].blank?
      clear_session
      redirect_to '/login' and return
    elsif session[:expires_at] < Time.current
      clear_session
      redirect_to '/login' and return
    end
  end

  def prevent_access_for_authenticated_user!
    redirect_to '/' if current_login.present?
  end

  def current_login
    raise NotImplementedError
  end

  def clear_session
    session[:login_id] = nil
    session[:expires_at] = nil
  end

  private

  def write_notice_to_header
    response.set_header('Alert-Message', flash[:notice]) if flash[:notice]
    response.set_header('Alert-Message', flash[:alert]) if flash[:alert]
  end
end

