class FeedbackMessage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type: String
  field :message, type: String
  field :name, type: String
  field :read, type: Boolean, default: false
end