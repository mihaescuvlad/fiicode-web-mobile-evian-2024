class Review
  include Mongoid::Document
  include Mongoid::Timestamps
  field :reviewer_id, type: BSON:ObjectId
  field :rating, type: Boolean
  field :comment, type: String
  field :helpful_votes, type: Integer
end
