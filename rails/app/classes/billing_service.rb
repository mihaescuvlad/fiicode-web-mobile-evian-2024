module BillingService
  def self.create_customer(user)
    Stripe::Customer.create(email: user.login.email, name: user.full_name, metadata: { user_id: user.id })[:id]
  end
  module Plus
    @@STRIPE_ID = 'prod_PsHay9NSi1ScNs'.freeze
    def self.get
      Stripe::Product.retrieve(@@STRIPE_ID)
    end
    def self.prices
      Stripe::Price.list(product: @@STRIPE_ID)
    end

    def self.create_checkout_session(user, price, return_url)
      Stripe::Checkout::Session.create({
        payment_method_types: ['card'],
        line_items: [{ price: price, quantity: 1}],
        mode: 'subscription',
        success_url: return_url,
        cancel_url: return_url,
        customer: user.stripe_customer_id
      })
    end

    def self.get_subscription(user)
      Stripe::Subscription.list(customer: user.stripe_customer_id).data.first rescue nil
    end

    def self.cancel_subscription(user)
      subscription = get_subscription(user)
      return if subscription.nil?
      Stripe::Subscription.cancel(subscription.id)
    end
  end
end
