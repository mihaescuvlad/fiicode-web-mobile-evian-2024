class Measurement
  include Mongoid::Document
  field :_id, type: BSON::ObjectId 
  field :unit, type: String
end
