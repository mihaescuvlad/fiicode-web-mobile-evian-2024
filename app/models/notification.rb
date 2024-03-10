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

  def self.create_product_review_notification!(product)
    verdict = product.status
    raise ArgumentError unless %i[APPROVED REJECTED].include?(verdict)

    if verdict == :APPROVED
      Notification.create!(user: product.submitted_by, message: "Your product #{product.name} was approved", link: "/products/#{product.id}", icon: "check-outline")
    else
      Notification.create!(user: product.submitted_by, message: "Your product #{product.name} was rejected", link: "/products/#{product.id}", icon: "close-outline")
    end

  end
end