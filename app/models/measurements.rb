class Measurements
  include Mongoid::Document
  field :_id, type: BSON::ObjectId 
  field :unit, type: String, required: true
end
