class Measurement
  include Mongoid::Document
  include Mongoid::Timestamps
  field :_id, type: BSON::ObjectId 
  field :unit, type: String
end
