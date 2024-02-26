class User::ProfilesController < UserApplicationController
  layout 'user_profile'

  before_action :authenticate_user!

  def show
    redirect_to "/profile/settings/user"
  end

  def user
  end

  def update_user
    current_user.update_attributes!(
      params.permit(:name, :full_name, :weight, :dietary_preferences, :height, :city, :country, allergens: [])
    )

    render json: { message: 'Profile updated' }, status: :ok
  end

  def account
    @login = Login.find_by(id: current_user.login_id)
  end

  def update_account
    if params[:password] != params[:password_confirmation]
      render json: { message: 'Password and password confirmation do not match' }, status: :bad_request and return
    end

    current_user.login.set_password(params[:password])
    render json: { message: 'Password updated' }, status: :ok
  end

  def dietary_preferences
    @dietary_preferences = User::DIETARY_PREFERENCES_VALUES
  end

  def update_dietary_preferences
    current_user.allergens_ids = params["allergens[]"]
    current_user.dietary_preferences = params[:dietary_preferences]
    current_user.save!

    render json: { message: 'Dietary preferences updated' }, status: :ok
  end

end
