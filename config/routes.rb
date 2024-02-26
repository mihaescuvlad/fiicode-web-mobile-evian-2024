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

    get '/profile', to: 'profiles#show'
    get '/profile/settings', to: 'profiles#show'
    get '/profile/settings/user', to: 'profiles#user'
    put '/profile/settings/user', to: 'profiles#update_user'
    get '/profile/settings/account', to: 'profiles#account'
    put '/profile/settings/account', to: 'profiles#update_account'
    get '/profile/settings/dietary_preferences', to: 'profiles#dietary_preferences'
    put '/profile/settings/dietary_preferences', to: 'profiles#update_dietary_preferences'

    resources :allergens, only: %i[index show] do
      get :search, on: :collection
    end

    resources :products do
      resources :reviews
    end
  end
end
