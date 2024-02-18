module Context
    def self.get_context(request)
        subomain = request.subdomain.downcase
        if subomain == "admin"
            return :admin
        elsif subomain == "www"
            return :user
        end
    end

    def self.current_domain(request)
        return "#{request.protocol}#{request.host_with_port}"
    end

end