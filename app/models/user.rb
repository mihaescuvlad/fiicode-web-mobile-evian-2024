class User
  include Mongoid::Document
  include Mongoid::Timestamps

  DIETARY_PREFERENCES_VALUES = [:NONE, :VEGETARIAN, :VEGAN]

  field :dietary_preferences, type: Symbol
  field :allergens_ids, type: Array, default: []
  field :favorites, type: Array, default: []

  field :first_name, type: String
  field :last_name, type: String

  field :weight, type: Integer
  field :height, type: Integer
  field :gender, type: String
  field :bio, type: String
  field :country, type: String
  field :city, type: String
  field :profile_picture, type: BSON::Binary

  has_many :submissions, class_name: 'Product', inverse_of: :submitted_by

  belongs_to :login
  has_many :notifications

  has_many :posts, class_name: 'Post', inverse_of: :author
  has_many :ratings

  field :interests, type: Array, default: []
  field :followers_ids, type: Array, default: []
  field :following_ids, type: Array, default: []

  def full_name
    "#{first_name} #{last_name}"
  end

  def followers
    User.where(:_id.in => followers_ids)
  end

  def following
    User.where(:_id.in => following_ids)
  end

  def following?(user)
    following_ids.include?(user.id)
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
      Notification.create_follow_notification!(self, user)
      s.commit_transaction
    end
  end

  def unfollow_and_save!(user)
    self.following_ids.delete(user.id)
    user.followers_ids.delete(self.id)

    User.with_session do |s|
      s.start_transaction
      self.save!
      user.save!
      s.commit_transaction
    end
  end

  def allergens
    return [] if allergens_ids.blank?

    Allergen.where(:off_id.in => allergens_ids)
  end
end
