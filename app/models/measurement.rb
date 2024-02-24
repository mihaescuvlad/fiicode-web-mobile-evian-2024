class Measurement
  include Mongoid::Document
  include Mongoid::Timestamps
  field :unit, type: String
end
