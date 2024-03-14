class User::ProfilesController < UserApplicationController
  layout 'user_profile'
  before_action :authenticate_user!, except: :account
  before_action :set_links

  def show
    render layout: 'user_application'
  end

  def user
    if request.put?
      current_user.update_attributes!(
        params.permit(:first_name, :last_name, :weight, :height, :city, :country)
      )
      render json: { message: 'Profile updated' }, status: :ok
    end
  end

  def account
    if current_user.present?
      @login = current_user.login
    elsif params[:login].present? and params[:token].present?
      @login = Login.find(params[:login]) rescue not_found
    else
      redirect_to user_login_path and return;
    end

    @token = params[:token]
    if @token.present? and @login.reset_password_key != @token
      redirect_to user_login_path, alert: "Invalid or expired password reset token" and return
    end
    @allowed_update = (params[:token].present? and @login.reset_password_key == params[:token])

    if request.put?
      if params[:password] != params[:password_confirmation]
        render json: { message: 'Password and password confirmation do not match' }, status: :bad_request and return
      end

      unless @allowed_update
        render json: { message: 'Invalid or expired password reset token' }, status: :unauthorized and return
      end

      @login.password = params[:password]
      @login.save!
      if current_user.present?
        render json: { message: 'Password updated' }, status: :ok
      else
        redirect_to user_login_path, notice: "Password updated", status: :see_other
      end
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

  def notifications
    @notifications = current_user.notifications.newest_first
  end

  protected

  def set_links
    if current_user.present?
      @links = [{ href: user_user_profile_path, text: "Profile", icon: "account" },
                { href: account_user_profile_path, text: "Account", icon: "lock" },
                { href: dietary_preferences_user_profile_path, text: "Preferences", icon: "food" },
                { href: user_hub_user_path(current_user), text: "Hub page", icon: "forum" },
                { href: notifications_user_profile_path, text: "Notifications", icon: "bell" }]
    else
      @links = []
    end
  end
end