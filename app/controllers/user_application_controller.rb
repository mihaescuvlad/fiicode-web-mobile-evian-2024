class UserApplicationController < ApplicationController
  layout 'user_application'

  def current_login
    return nil if session[:login_id].blank?
    @current_login ||= Login.find(session[:login_id]["$oid"]) rescue nil
  end

  def current_user
    current_login.user rescue nil
  end

  helper_method :current_user
end