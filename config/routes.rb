Rails.application.routes.draw do
  resources :reviews
  resources :products
  resources :measurements
  resources :allergens
  resources :dietary_preferences
  resources :users
  scope module: 'user', constraints: ->(req) { Context.get_context(req) == :user } do
    root to: 'welcome#index'
    match '/', to: 'welcome#index', via: :all
    match '/login', to: 'sessions#login', via: %i[post get]
    match '/register', to: 'sessions#register', via: %i[post get]
  end

  get '/products', to: 'products#index'
end
