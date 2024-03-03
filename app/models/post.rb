class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  validates_presence_of :title
  after_create :notify_mentions

  field :title, type: String
  field :content, type: String
  field :images, type: Array, default: []
  has_one :author, class_name: 'User', inverse_of: :posts

  field :hashtags, type: Array

  has_many :ratings do
    def vote(user)
      where(user: user).first.vote
    end
  end

  has_many :responses, class_name: 'Post', inverse_of: :response_to
  belongs_to :response_to, class_name: 'Post', inverse_of: :responses, optional: true

  def initialize(attrs = {})
    raise ArgumentError unless attrs.keys.include?(:title)

    super
  end

  def title=(title)
    raise ArgumentError, "Title cannot be blank" if title.blank?

    set_hashtags
    write_attribute(:title, title)
  end

  def title_as_html
    sanitized = ActionController::Base.helpers.sanitize(title)

    # TODO: [FII-49] Convert mentions and hashtags to links

    sanitized.html_safe
  end

  def content=(content)
    raise ArgumentError, "Content cannot be blank" if content.blank?

    set_hashtags
    write_attribute(:content, content)
  end

  def content_as_html
    sanitized = ActionController::Base.helpers.sanitize(content)

    # TODO: [FII-49] Convert mentions and hashtags to links

    sanitized.html_safe
  end

  def response_to=(post)
    if post.response_to != nil
      raise ArgumentError, "Post cannot be a response to another response"
    else
      write_attribute("response_to_id", post.id)
    end
  end

  def hashtags=(_)
    raise NoMethodError
  end

  def mentions
    "#{title}\n#{content}".scan(/@\w+/)
                          .map { |mention| mention[1..] }
                          .map { |username| Login.where(username: username).first }
                          .filter { |login| login != nil }
                          .map { |login| login.user }
  end

  private

  def set_hashtags
    write_attribute(
      :hashtags,
      "#{title}\n#{content}".scan(/#\w+/).map { |hashtag| hashtag[1..] }
    )
  end

  def notify_mentions
    mentions.each do |user|
      Notification.create_mention_notification!(user, self)
    end
  end
end