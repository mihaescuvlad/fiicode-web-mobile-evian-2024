class User::ProfilesController < UserApplicationController
    before_action :authenticate_user!

    def show
        @login = Login.find_by(id: current_user.login_id)
    end

    def update
        user = User.find_by(login_id: session[:login_id]["$oid"])
        user.update_attributes!(user_params)
        redirect_to user_profile_path
    end

    private

    def user_params
        params.require(:profile).permit(:name, :full_name, :weight, :height, :city, :country)
    end

end
