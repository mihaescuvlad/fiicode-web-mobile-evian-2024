Rails.application.routes.draw do
  resources :measurements
  resources :allergens
  resources :dietary_preferences
  scope module: 'user', constraints: ->(req) { Context.get_context(req) == :user }, name_path: 'user', as: 'user' do
    root to: 'welcome#index'
    match '/', to: 'welcome#index', via: :all
    match '/search', to: 'welcome#search', via: :all
    match '/scan', to: 'welcome#scan', via: :all
    match '/hub', to: 'welcome#hub', via: :all
    match '/login', to: 'sessions#login', via: %i[post get]
    match '/register', to: 'sessions#register', via: %i[post get]

    resource :profile, only: %i[show edit update]

  end
end
