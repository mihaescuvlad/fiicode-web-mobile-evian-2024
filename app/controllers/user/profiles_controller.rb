class User::ProfilesController < UserApplicationController
    before_action :authenticate_user!

    def show
        @login = Login.find_by(id: current_user.login_id)
        @dietary_preferences = User::DIETARY_PREFERENCES_VALUES
    end

    def update
        user = User.find_by(login_id: session[:login_id]["$oid"])
        user.update_attributes!(user_params)
        password = login_params[:password]
        confirmation = login_params[:password_confirmation]
        if password.present? && confirmation.present? 
            if password != confirmation
                render json: { message: 'Password and password confirmation do not match' }, status: :unauthorized and return
            end
            login = Login.find_by(id: user.login_id)
            login.set_password(password)
        end


        redirect_to user_profile_path
    end

    private

    def user_params
        params.require(:profile).permit(:name, :full_name, :weight, :dietary_preferences, :height, :city, :country, allergens: [])
    end

    def login_params
        params.require(:login).permit(:password, :password_confirmation)
    end

end
