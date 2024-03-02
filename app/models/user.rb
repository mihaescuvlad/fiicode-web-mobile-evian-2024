class User
  include Mongoid::Document
  include Mongoid::Timestamps

  DIETARY_PREFERENCES_VALUES = [:vegetarian, :vegan, :pescetarian, :gluten_free, :dairy_free, :nut_free, :soy_free, :egg_free, :shellfish_free, :no_restrictions]

  field :dietary_preferences, type: Symbol
  field :allergens_ids, type: Array, default: []

  field :first_name, type: String
  field :last_name, type: String

  def full_name
    "#{first_name} #{last_name}"
  end

  field :weight, type: Integer
  field :height, type: Integer
  field :gender, type: String
  field :bio, type: String
  field :country, type: String
  field :city, type: String
  field :profile_picture, type: BSON::Binary
  belongs_to :login
  has_many :notifications

  has_many :posts, class_name: 'Post', inverse_of: :author
  has_many :ratings

  field :interests, type: Array, default: []
  field :followers_ids, type: Array, default: []
  field :following_ids, type: Array, default: []

  def followers
    User.where(:_id.in => followers_ids)
  end

  def following
    User.where(:_id.in => following_ids)
  end

  def follow_and_save!(user)
    unless self.following_ids.include?(user.id)
      self.following_ids << user.id
    end

    unless user.followers_ids.include?(self.id)
      user.followers_ids << self.id
    end

    User.with_session do |s|
      s.start_transaction
      self.save!
      user.save!
      notify_follow(user)
      s.commit_transaction
    end
  end

  def allergens
    return [] if allergens_ids.blank?

    Allergen.where(:off_id.in => allergens_ids)
  end

  private

  def notify_follow(user)
    Notification.create!(user: user, message: "#{self.full_name} started following you", link: "/hub/user/#{user.id}", icon: :account)
  end
end
