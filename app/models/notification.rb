class Notification
  include Mongoid::Document
  include Mongoid::Timestamps

  scope :newest_first, -> { order_by(created_at: :desc) }

  belongs_to :user
  field :message, type: String
  field :link, type: String
  field :icon, type: String
  field :read, type: Boolean, default: false

  def self.create_follow_notification!(follower, followed)
    Notification.create!(user: followed, message: "#{follower.full_name} started following you", link: "/hub/users/#{follower.id}", icon: "account-outline")
  end

  def self.create_mention_notification!(user, post)
    Notification.create!(user: user, message: "You were mentioned in a post", link: "/hub/posts/#{post.id}", icon: "at")
  end

  def self.create_response_notification!(user, post)
    Notification.create!(user: user, message: "#{user.last_name} responded to your post", link: "/hub/posts/#{post.id}", icon: "message-reply-outline")
  end
end