class Allergen
  include Mongoid::Document
  field :_id, type: BSON::ObjectId
  field :name, type: String
end
