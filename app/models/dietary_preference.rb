class DietaryPreference
  include Mongoid::Document
  include Mongoid::Timestamps
  field :_id, type: BSON::ObjectId
  field :name, type: String
end
