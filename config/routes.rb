Rails.application.routes.draw do
  scope module: 'user', constraints: ->(req) { Context.get_context(req) == :user }, name_path: 'user', as: 'user' do
    root to: 'welcome#index'
    match '/', to: 'welcome#index', via: :all
    match '/search', to: 'welcome#search', via: :all
    match '/scan', to: 'welcome#scan', via: :all
    match '/hub', to: 'welcome#hub', via: :all
    match '/login', to: 'sessions#login', via: %i[post get]
    match '/register', to: 'sessions#register', via: %i[post get]
    match '/logout', to: 'sessions#logout', via: :all
    resource :profile, only: %i[show edit update]

    namespace :product, name_path: 'products' do
      resources :products
    end
  end
end
