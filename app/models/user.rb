class User
  include Mongoid::Document
  include Mongoid::Timestamps::Short
  field :login_data, type: BSON::ObjectId
  field :name, type: String

  field :dietary_preferences, type: Array
  field :allergens, type: Array
  
  field :weight, type: Integer
  field :height, type: Integer
  field :gender, type: String
  field :bio, type: String
  field :location, type: String
  field :profile_picture, type: BSON::Binary
  
  field :administrator, type: Boolean
end
