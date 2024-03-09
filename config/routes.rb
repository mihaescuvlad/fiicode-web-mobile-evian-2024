Rails.application.routes.draw do
  scope module: 'user', constraints: ->(req) { Context.get_context(req) == :user }, name_path: 'user', as: 'user' do
    root to: 'welcome#index'
    match '/', to: 'welcome#index', via: :all
    match '/search', to: 'welcome#search', via: :all
    match '/scan', to: 'welcome#scan', via: :all
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
      match :create_product, on: :collection, via: %i[get post]
      get :search_by_ean, on: :collection
      get :search, on: :collection
      resources :reviews
    end

    resources :submissions, only: %i[index show]

    namespace :hub do
      get '/', to: 'hub#index'
      get 'following', to: 'hub#following'
      get 'hashtag/:hashtag', to: 'hub#hashtag'
      get 'for_you', to: 'hub#for_you'
      resources :posts, only: %i[show new create]
      post 'posts/:post_id/rating', to: 'ratings#create'
      delete 'posts/:post_id/rating', to: 'ratings#destroy'
      resources :users, only: %i[show] do
        get '/follow', to: 'users#follow'
      end
    end
  end

  scope module: 'admin', constraints: ->(req) { Context.get_context(req) == :admin }, name_path: 'admin', as: 'admin' do
    root to: 'submissions#index'
    match '/', to: 'welcome#index', via: :all

    match '/login', to: 'sessions#login', via: %i[post get]
    match '/logout', to: 'sessions#logout', via: %i[post]

    resources :submissions

    resources :products do
      put :approve, on: :member
      put :reject, on: :member
    end
  end
end
