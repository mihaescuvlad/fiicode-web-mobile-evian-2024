class User
  include Mongoid::Document
  include Mongoid::Timestamps::Short
  field :_id, type: BSON::ObjectId
  field :login_data, type: BSON::ObjectId

  field :dietary_preferences, type: Array
  field :allergens, type: Array
  
  field :weight, type: Integer
  field :height, type: Integer
  field :gender, type: Integer
  field :bio, type: String
  field :location, type: String
  field :profile_picture, type: BSON::Binary
  
  field :administrator, type: Boolean
end
