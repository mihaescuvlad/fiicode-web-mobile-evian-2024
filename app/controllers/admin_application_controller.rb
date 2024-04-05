class AdminApplicationController < ApplicationController
  layout 'admin_application'

  def current_login
    return nil if session[:login_id].blank?
    @current_login ||= Admin.find(session[:login_id]) rescue nil
  end

  helper_method :current_login
end