class User::ProfilesController < UserApplicationController
  layout 'user_profile'
  before_action :authenticate_user!
  before_action :set_links

  def show; end

  def user
    if request.put?
      current_user.update_attributes!(
        params.permit(:first_name, :last_name, :weight, :height, :city, :country)
      )
      render json: { message: 'Profile updated' }, status: :ok
    end
  end

  def account
    @login = current_user.login

    if request.put?
      if params[:password] != params[:password_confirmation]
        render json: { message: 'Password and password confirmation do not match' }, status: :bad_request and return
      end
  
      @login.set_password(params[:password])
      render json: { message: 'Password updated' }, status: :ok
    end
  end

  def dietary_preferences
    @dietary_preferences = User::DIETARY_PREFERENCES_VALUES

    if request.put?
      current_user.allergens_ids = params["allergens[]"]
      current_user.dietary_preferences = params[:dietary_preferences]
      current_user.save!
  
      render json: { message: 'Dietary preferences updated' }, status: :ok
    end
  end

  protected

  def set_links
    @links = [{ href: user_user_profile_path, text: "Profile", icon: "account" },
              { href: account_user_profile_path, text: "Account", icon: "lock" },
              { href: dietary_preferences_user_profile_path, text: "Preferences", icon: "food" }]
  end
end
