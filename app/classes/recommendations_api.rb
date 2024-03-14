require 'http'

class RecommendationsApi
  @@API = 'http://localhost:5000'.freeze


  def self.products(user)
    if user.blank?
      return []
    end
    
    response = get(@@API, "/products/" + user._id.to_s)
    return nil if response["products"].nil?

    response["products"]
  end

  def self.paginated_products(user, page = 1, per_page = 10)
    page = 1 if page.blank?
    if user.blank?
      return []
    end
    
    response = get(@@API, "/products/page/" + page.to_s + "/" + user._id.to_s + "?per_page=" + per_page.to_s)
  end

  def self.get(api, endpoint)
    res = HTTP.get(api + endpoint)
    unless res.status.success?
      return nil
    end

    JSON.parse res.body
  end
end
