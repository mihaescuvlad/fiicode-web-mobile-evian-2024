class User
  include Mongoid::Document
  include Mongoid::Timestamps

  DIETARY_PREFERENCES_VALUES = [:vegetarian, :vegan, :pescetarian, :gluten_free, :dairy_free, :nut_free, :soy_free, :egg_free, :shellfish_free, :no_restrictions]

  field :dietary_preferences, type: Symbol
  field :allergens_ids, type: Array, default: []

  field :first_name, type: String
  field :last_name, type: String
  field :weight, type: Integer
  field :height, type: Integer
  field :gender, type: String
  field :bio, type: String
  field :country, type: String
  field :city, type: String
  field :profile_picture, type: BSON::Binary
  belongs_to :login, class_name: 'Login', inverse_of: :user

  def allergens
    return [] if allergens_ids.blank?
    
    Allergen.where(:off_id.in => allergens_ids)
  end
end
