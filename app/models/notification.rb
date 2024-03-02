class Notification
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  field :message, type: String
  field :link, type: String
  field :icon, type: String
  field :read, type: Boolean, default: false
end