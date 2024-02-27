require 'net/http'

Rails.application.config.after_initialize do
Thread.new do
    Rails.cache.fetch('allergens_list', expires_in: 24.hours) do
        api_url = 'https://world.openfoodfacts.org/allergens.json'
        response = Net::HTTP.get(URI(api_url))
        allergens = JSON.parse(response)['tags']
        allergens.select { |tag|
            tag['name'].first >= 'A' && tag['name'].first <= 'Z'
        }.map { |tag|
            tag['name'].gsub(/.*:/, '')
        }
        end
    end      
end