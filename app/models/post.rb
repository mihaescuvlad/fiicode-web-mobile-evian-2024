class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  scope :top_level, -> { where(response_to: nil) }
  scope :response, ->() { self.not(top_level) }

  scope :newest_first, -> { order_by(created_at: :desc) }
  scope :by_notoriety, -> { order_by(notoriety: :desc) }

  validates_presence_of :title
  after_create :notify

  field :title, type: String
  field :content, type: String
  field :images, type: Array, default: []
  belongs_to :author, class_name: 'User', inverse_of: :posts

  field :hashtags, type: Array

  field :viewer_ids, type: Array, default: []

  has_many :ratings do
    def vote(user)
      find_by(user: user).vote rescue nil
    end

    def votes(vote, timeframe = nil)
      query = where(vote: vote)
      if timeframe
        query = query.where(:created_at.gte => DateTime.now - timeframe)
      end

      query.length
    end

    def upvotes(timeframe = nil)
      votes(:up_vote, timeframe)
    end

    def downvotes(timeframe = nil)
      votes(:down_vote, timeframe)
    end

    def ratio(timeframe = nil)
      upvotes(timeframe) - downvotes(timeframe)
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

    write_attribute(:title, title)
    set_hashtags
  end

  def title_as_html
    sanitized = ActionController::Base.helpers.sanitize(title)

    replace_links!(sanitized)

    sanitized.html_safe
  end

  def content=(content)
    if content.blank?
      write_attribute(:content, nil) and return
    end

    write_attribute(:content, content)
    set_hashtags
  end

  def content_as_html
    sanitized = ActionController::Base.helpers.sanitize(content)

    replace_links!(sanitized)

    sanitized = sanitized.split("\n").map { |line| "<p>#{line}</p>" }.join.html_safe

    sanitized.html_safe
  end

  def hashtags=(_)
    raise NoMethodError
  end

  def viewer_ids=(_)
    raise NoMethodError
  end

  def view(user)
    viewer_ids << user.id unless viewer_ids.include?(user.id)
  end

  def views
    viewer_ids.length
  end

  def mentions
    "#{title}\n#{content}".scan(/@\w+/)
                          .map { |mention| mention[1..] }
                          .map { |username| Login.where(username: username).first }
                          .filter { |login| login != nil }
                          .map { |login| login.user }
  end

  def notoriety
    comment_weight = 10
    vote_weight = 1
    timeframe = 1.days

    responses.length(timeframe) * comment_weight + ratings.ratio(timeframe).abs * vote_weight
  end

  def self.recommend_following(user, chunk = 0)
    chunk_size = 5

    @posts = Post
               .where(:author.in => user.following)
               .top_level
               .newest_first
               .limit(chunk_size)
               .offset(chunk * chunk_size)
  end

  private

  def set_hashtags
    write_attribute(
      :hashtags,
      "#{title} #{content}".scan(/#\w+/).map { |hashtag| hashtag[1..] }
    )
  end

  def replace_links!(str)
    self.hashtags.each do |hashtag|
      str.sub!("\##{hashtag}", "<a class='text-primary-500' href='/hub/hashtag/#{hashtag}'>\##{hashtag}</a>")
    end

    self.mentions.each do |user|
      str.sub!("@#{user.login.username}", "<a class='text-primary-500' href='/hub/users/#{user.id}'>@#{user.login.username}</a>")
    end

    str
  end

  def notify
    mentions.each do |user|
      Notification.create_mention_notification!(user, self)
    end

    if response_to.present?
      Notification.create_response_notification!(response_to.author, self)
    end
  end
end