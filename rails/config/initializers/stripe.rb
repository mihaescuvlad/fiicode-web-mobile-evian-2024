require 'stripe'

Stripe.api_key = Rails.application.credentials.dig(:apis, :stripe_key)