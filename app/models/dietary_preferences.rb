class DietaryPreferences
  include Mongoid::Document
  field :_id, type: BSON::ObjectId
  field :name, type: String, required: true
end
