class User::WelcomeController < UserApplicationController
  def index
    @top_products = ProductsRecommendation.filter_products_with_aggregation(current_user, 3, 0)
    @top_posts = top_posts
    @food_fact = Recipe.desc(:created_at).first
    if @food_fact.nil? || @food_fact.created_at < 30.minutes.ago
      @food_fact = RandomFacts.random_recipe
      @food_fact.save
    end

    if current_user.present?
      recommendation_products = RecommendationsApi.paginated_products(current_user, 1, 3)
      @recommended_products = Product.where(:_id.in => recommendation_products["products"])
    end
  end

  def search
  end

private

  def top_posts
    pipeline = [
      {
        '$lookup' => {
          'from' => 'ratings',
          'localField' => '_id',
          'foreignField' => 'post_id',
          'as' => 'ratingDetails'
        }
      },
      {
        '$project' => {
          'title' => 1,
          'content' => 1,
          'up_number' => {
            '$size' => {
              '$filter' => {
                'input' => '$ratingDetails',
                'as' => 'rating',
                'cond' => { '$eq' => ['$$rating.vote', 'up_vote'] }
              }
            }
          },
          'down_number' => {
            '$size' => {
              '$filter' => {
                'input' => '$ratingDetails',
                'as' => 'rating',
                'cond' => { '$eq' => ['$$rating.vote', 'down_vote'] }
              }
            }
          }
        }
      },
      {
        '$lookup' => {
          'from' => 'posts',
          'localField' => '_id',
          'foreignField' => 'response_to',
          'as' => 'replies'
        }
      },
      {
        '$addFields' => {
          'replies_number' => { '$size' => '$replies' }
        }
      },
      {
        '$addFields' => {
          'overall_ratings' => { '$add' => ['$up_number', '$down_number'] }
        }
      },
      { '$sort' => { 'overall_ratings' => -1 } },
      { '$limit' => 3 }
    ]

    Post.collection.aggregate(pipeline).to_a
  end
end
