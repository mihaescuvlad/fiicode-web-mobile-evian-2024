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
  field :login_id, type: BSON::ObjectId

  field :administrator, type: Boolean

  def login
    Login.find(login_id)
  end

  def allergens
    allergens_ids.map { |id| Allergen.find(id) }
  end
end
