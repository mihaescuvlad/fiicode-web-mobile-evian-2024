module ProductsRecommendation
  def self.filter_products_with_aggregation(user, limit = 5, skip = 0)
    pipeline = []
  
    pipeline << {
      '$match': { 'status': 'APPROVED' }
    }
  
    pipeline << {
      '$lookup': {
        from: 'reviews',
        localField: '_id',
        foreignField: 'product_id',
        as: 'reviews'
      }
    }
  
    pipeline << {
      '$addFields': {
        'total_reviews': { '$size': '$reviews' },
        'positive_reviews': {
          '$size': {
            '$filter': {
              'input': '$reviews',
              'as': 'review',
              'cond': '$$review.rating'
            }
          }
        }
      }
    }
  
    pipeline << {
      '$addFields': {
        'positive_review_percentage': {
          '$cond': {
            'if': { '$eq': ['$total_reviews', 0] },
            'then': -1,
            'else': { '$multiply': [{ '$divide': ['$positive_reviews', '$total_reviews'] }, 100] }
          }
        }
      }
    }
  
    pipeline << {
      "$addFields": {
        "nutriscore_adjustment": {
          "$switch": {
            "branches": [
              { "case": { "$eq": ["$nutriscore", "a"] }, "then": 100 },
              { "case": { "$eq": ["$nutriscore", "b"] }, "then": 70 },
              { "case": { "$eq": ["$nutriscore", "c"] }, "then": 50 },
              { "case": { "$eq": ["$nutriscore", "d"] }, "then": 20 },
              { "case": { "$eq": ["$nutriscore", "e"] }, "then": 0 }
            ],
            "default": 0
          }
        }
      }
    }
  
    pipeline << {
      "$addFields": {
        "overall_score": {
          "$add": [
            { "$multiply": ["$positive_review_percentage", 0.65] },
            { "$multiply": ["$nutriscore_adjustment", 0.35] }
          ]
        }
      }
    }

    pipeline << { '$unset': ['reviews', 'positive_reviews', 'total_reviews', 'positive_review_percentage', 'allergen_penalty', 'dietary_preference_penalty', 'nutriscore_adjustment'] }
  
    pipeline << { '$skip': skip } if skip > 0
    pipeline << { '$limit': limit } if limit > 0
  
    pipeline << { '$sort': { 'overall_score': -1 } }
  
    map_aggregate_to_products(Product.collection.aggregate(pipeline))
  end
  
  private

  def self.map_aggregate_to_products(aggregated_products)
    aggregated_products.map do |doc|
      product_attrs = doc.symbolize_keys
      product = Product.new(product_attrs)
      product.define_singleton_method(:persisted?) { true }
      product
    end
  end
end