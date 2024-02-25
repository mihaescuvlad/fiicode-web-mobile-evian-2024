class Allergen
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :off_counterpart, type: String, default: -> { name.downcase if name.present? }
end
