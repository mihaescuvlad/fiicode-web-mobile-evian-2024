require 'net/http'
require 'json'

Rails.application.config.after_initialize do
  Thread.new do
    loop do
      begin
        uri = URI('https://world.openfoodfacts.org/allergens.json')
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.open_timeout = 5
        http.read_timeout = 5
        
        response = http.get(uri)
        allergens = JSON.parse(response.body)['tags']
        
        selected_allergens = allergens.select do |tag|
          tag['name'].first >= 'A' && tag['name'].first <= 'Z'
        end.map do |tag|
          { name: tag['name'].gsub(/.*:/, ''), id: tag['id'] }
        end
        
        selected_allergens.each do |allergen|
          Allergen.find_or_create_by(name: allergen[:name], off_id: allergen[:id])
        end
        
        # Return the processed allergens to cache them
      rescue Net::OpenTimeout, Net::ReadTimeout => e
        Rails.logger.error "Timeout error: #{e.message}"
      rescue JSON::ParserError => e
        Rails.logger.error "JSON parsing error: #{e.message}"
      rescue => e
        Rails.logger.error "General error: #{e.message}"
      end
      
      # Sleep for a while before the next iteration. Adjust the sleep duration as needed.
      # This is outside the `begin...rescue` block to ensure the loop continues even after an error.
      sleep 24.hours
    end
  end
end
