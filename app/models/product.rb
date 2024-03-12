require 'set'

class Product
  include Mongoid::Document
  include Mongoid::Timestamps
  
  before_save :notify_review

  APPROVED_STATUSES = %i[PENDING APPROVED REJECTED]

  field :ean, type: String, as: :id
  field :brand, type: String
  field :name, type: String
  field :price, type: Float
  field :weight, type: String
  field :allergens, type: Array
  field :vegan, type: Boolean
  field :vegetarian, type: Boolean
  field :ingredients, type: Array
  field :calories, type: Float
  field :fat, type: Float
  field :saturated_fat, type: Float
  field :polysaturated_fat, type: Float
  field :monosaturated_fat, type: Float
  field :trans_fat, type: Float
  field :carbohydrates, type: Float
  field :fiber, type: Float
  field :sugar, type: Float
  field :protein, type: Float
  field :sodium, type: Float
  field :vitamin_A, type: Float
  field :vitamin_C, type: Float
  field :calcium, type: Float
  field :iron, type: Float
  field :status, type: Symbol, default: :PENDING
  field :rating, type: Integer, default: 0
  field :nutriscore, type: String

  belongs_to :submitted_by, class_name: "User", inverse_of: :submissions

  def status=(status)
    raise ArgumentError unless APPROVED_STATUSES.include?(status)
    super
  end

  def self.from_open_food_facts(ean)
    OpenFoodFacts.product(ean)
  end

  def approved?
    status == :APPROVED
  end

  private

  def notify_review
    return unless status != :PENDING

    saved_product = Product.find(id) rescue return
    return unless saved_product.status != status

    Notification.create_product_review_notification!(self)
  end
end
