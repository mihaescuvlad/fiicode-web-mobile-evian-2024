class Allergen
  include Mongoid::Document
  include Mongoid::Timestamps
  field :_id, type: BSON::ObjectId
  field :name, type: String
  field :off_counterpart, type: String, default: -> { name.downcase if name.present? }
end
