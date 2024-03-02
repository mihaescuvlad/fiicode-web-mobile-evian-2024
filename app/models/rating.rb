class Rating
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :post
  belongs_to :user
  field :vote, type: StringifiedSymbol

  def vote=(vote)
    raise ArgumentError unless [:up_vote, :down_vote].include?(vote)
    write_attribute(:vote, vote)
  end
end