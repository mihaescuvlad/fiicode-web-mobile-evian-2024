class Notification
  include Mongoid::Document
  include Mongoid::Timestamps

  private_class_method :new, :create, :create!

  belongs_to :user
  field :message, type: String
  field :link, type: String
  field :icon, type: String
  field :read, type: Boolean, default: false

  def self.create_follow_notification!(follower, followed)
    Notification.create!(user: followed, message: "#{follower.full_name} started following you", link: "/hub/user/#{follower.id}", icon: :account)
  end

  def self.create_mention_notification!(user, post)
    Notification.create!(user: user, message: "You were mentioned in a post", link: "/hub/post/#{post.id}", icon: :at)
  end
end