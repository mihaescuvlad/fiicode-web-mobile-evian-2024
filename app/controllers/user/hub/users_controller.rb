class User::Hub::UsersController < UserApplicationController
  before_action :authenticate_user!, only: %i[follow followers following]

  def show
    @user = User.find(params[:id]) rescue not_found
  end

  def follow
    user = User.find(params[:user_id]) rescue not_found
    if current_user.following?(user)
      current_user.unfollow_and_save!(user)
    else
      current_user.follow_and_save!(user)
    end

    redirect_to action: :show, id: user.id
  end

  def followers
    @user = User.find(params[:user_id]) rescue not_found
  end

  def following
    @user = User.find(params[:user_id]) rescue not_found
  end
end
