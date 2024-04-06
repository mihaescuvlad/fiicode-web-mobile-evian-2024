class User
  include Mongoid::Document
  include Mongoid::Timestamps

  DIETARY_PREFERENCES_VALUES = [:NONE, :VEGETARIAN, :VEGAN]

  scope :most_experienced, -> { order_by(xp: :desc) }

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

  field :goal_title, type: String
  field :goal_description, type: String
  field :goal_created_at, type: DateTime
  field :goal_progress, type: Integer
  field :goal_target, type: Integer

  @@LEVEL_1_TRESHOLD = 500
  @@MULTIPLIER = 1.1
  field :xp, type: Integer, default: 0
  field :points, type: Integer, default: 0

  mount_uploader :profile_picture, ProfilePictureUploader

  has_many :submissions, class_name: 'Product', inverse_of: :submitted_by

  belongs_to :login
  has_many :notifications

  has_many :posts, class_name: 'Post', inverse_of: :author
  has_many :ratings

  field :interests, type: Array, default: []
  field :followers_ids, type: Array, default: []
  field :following_ids, type: Array, default: []

  def award_cost
    if has_membership? then 10 else 25 end
  end

  def purchase_award
    raise "Not enough points to purchase award" if points < award_cost

    self.points -= award_cost
  end

  def add_xp(xp)
    self.xp += xp
  end

  def level_f
    Math.log(xp*(@@MULTIPLIER - 1)/@@LEVEL_1_TRESHOLD + 1, @@MULTIPLIER)
  end

  def level
    level_f.floor
  end

  def stripe_customer_id
    id = read_attribute(:stripe_customer_id)
    id ||= BillingService.create_customer(self)
    self.update_attribute(:stripe_customer_id, id)
    id
  end

  private
  def stripe_customer_id=(id)
    write_attribute(:stripe_customer_id, id)
  end

  public

  def has_membership?
    BillingService::Plus.get_subscription(self).present?
  end

  def profile_picture_url
    self.profile_picture&.url || ActionController::Base.helpers.asset_path("account-circle-outline.png")
  end

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

  def diary_products(date = Date.today)
    Diary.where(user_id: self.id).and("products.#{date.strftime('%Y-%m-%d')}".to_sym.exists => true).first.try(:products).try(:[], date.strftime('%Y-%m-%d')) || []
  end

  def get_nutritional_targets
    calorie_target = 2000
  
    unless self.height.nil?
      calorie_target = self.height * 2.2 * 14
    end
  
    {
      calorie_target: calorie_target,
      protein_target: (calorie_target * 0.3 / 4).round(2),
      carbs_target: (calorie_target * 0.4 / 4).round(2),
      fat_target: (calorie_target * 0.3 / 9).round(2)
    }
  end
  
  def get_nutritional_stats(date = Date.today)
    nutritional_targets = get_nutritional_targets
  
    calorie_eaten = 0
    protein_eaten = 0
    carbs_eaten = 0
    fat_eaten = 0
  
    fetched_diary_products = diary_products(date)
  
    if fetched_diary_products.present?
      fetched_diary_products.each do |diary_product|
        product = Product.find_by(_id: diary_product["product_id"])
  
        calorie_eaten += (product.calories / 100 * diary_product["quantity"]).round(2)
        protein_eaten += (product.protein / 100 * diary_product["quantity"]).round(2)
        carbs_eaten += (product.carbohydrates / 100 * diary_product["quantity"]).round(2)
        fat_eaten += (product.fat / 100 * diary_product["quantity"]).round(2)
      end
    end
    
    {
      calorie_eaten: calorie_eaten,
      protein_eaten: protein_eaten,
      carbs_eaten: carbs_eaten,
      fat_eaten: fat_eaten,
      **nutritional_targets
    }
  end

  def get_nutritional_stats_last_30_days
    nutritional_stats = []
    date = Date.today
    30.times do
      nutritional_stats << get_nutritional_stats(date)
      date -= 1.day
    end
    nutritional_stats.reverse
  end

  def compute_nutritional_goal
    nutritional_stats = get_nutritional_stats

    calorie_goal = nutritional_stats[:calorie_target]
    protein_goal = nutritional_stats[:protein_target]
    carbs_goal = nutritional_stats[:carbs_target]
    fat_goal = nutritional_stats[:fat_target]

    calorie_eaten = nutritional_stats[:calorie_eaten]
    protein_eaten = nutritional_stats[:protein_eaten]
    carbs_eaten = nutritional_stats[:carbs_eaten]
    fat_eaten = nutritional_stats[:fat_eaten]

    calorie_completeness = (calorie_eaten / calorie_goal * 100).round(2)
    protein_completeness = (protein_eaten / protein_goal * 100).round(2)
    carbs_completeness = (carbs_eaten / carbs_goal * 100).round(2)
    fat_completeness = (fat_eaten / fat_goal * 100).round(2)

    overall_completeness = [calorie_completeness, protein_completeness, carbs_completeness, fat_completeness].min

    # cookies[:wellness_completeness_ratio] = {
    #   value: overall_completeness,
    #   expires: Time.current.end_of_day
    # }

    # midnight = Time.current.end_of_day

    # cookies[:nutritional_completeness_ratio] ||= { value: overall_completeness, expires: midnight }
  end
end
