class Recipe
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :vegan, type: Boolean
  field :vegetarian, type: Boolean
  field :ready_in, type: Integer
  field :instructions, type: String
end