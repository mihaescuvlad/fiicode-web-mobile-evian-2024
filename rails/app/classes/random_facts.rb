class RandomFacts
  require 'uri'
  require 'net/http'
  @@API = 'https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com'.freeze

  def self.random_recipe
    url = URI("#{@@API}/recipes/random?number=1")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Key"] = Rails.application.credentials.dig(:apis, :rapid_api_key)
    request["X-RapidAPI-Host"] = 'spoonacular-recipe-food-nutrition-v1.p.rapidapi.com'

    response = http.request(request)
    response = JSON.parse(response.read_body)
    
    response['recipes'].map do |recipe|
      Recipe.new(
        title: recipe['title'],
        vegan: recipe['vegan'],
        vegetarian: recipe['vegetarian'],
        ready_in: recipe['readyInMinutes'],
        instructions: recipe['instructions']
      )
    end.first
  end
end