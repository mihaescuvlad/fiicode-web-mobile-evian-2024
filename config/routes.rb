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

    resource :profile, only: %i[show index] do
      match :user, on: :collection, via: %i[get put]
      match :account, on: :collection, via: %i[get put]
      match :dietary_preferences, on: :collection, via: %i[get put]
    end

    resources :allergens, only: %i[index show] do
      get :search, on: :collection
    end

    resources :products do
      resources :reviews
    end
  end
end
