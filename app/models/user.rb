class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String

  field :dietary_preferences, type: Array
  field :allergens, type: Array
  
  field :full_name, type: String
  field :weight, type: Integer
  field :height, type: Integer
  field :gender, type: String
  field :bio, type: String
  field :country, type: String
  field :city, type: String
  field :profile_picture, type: BSON::Binary
  field :login_id, type: BSON::ObjectId
  
  field :administrator, type: Boolean
end
