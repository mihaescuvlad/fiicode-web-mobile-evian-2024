class ApplicationController < ActionController::Base
    
    def authenticate_user!
        if session[:login_id].blank?
            clear_session
            redirect_to login_path and return
        elsif session[:expires_at] < Time.current
            clear_session
            redirect_to login_path and return
        end
    end

    def prevent_access_for_authenticated_user!
        redirect_to root_path if session[:login_id].present? #TODO: Change session to current_user
    end

    def clear_session
        session[:login_id] = nil
        session[:expires_at] = nil
    end

    def current_user
        return nil if session[:login_id].blank?
        @current_user ||= User.find_by(login_id: session[:login_id])
    end

end

