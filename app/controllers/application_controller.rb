class ApplicationController < ActionController::Base
    layout 'user_application'

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
        redirect_to '/' if current_user.present?
    end

    def clear_session
        session[:login_id] = nil
        session[:expires_at] = nil
    end

    def current_user
        return nil if session[:login_id].blank?
        @current_user ||= User.find_by(login_id: session[:login_id]["$oid"]) rescue nil
    end

    helper_method :current_user
end

