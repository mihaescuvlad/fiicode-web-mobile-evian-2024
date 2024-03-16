Rails.application.routes.draw do
  scope module: 'user', constraints: ->(req) { Context.get_context(req) == :user }, name_path: 'user', as: 'user' do
    root to: 'welcome#index'
    match '/', to: 'welcome#index', via: :all
    match '/search', to: 'welcome#search', via: :all
    match '/login', to: 'sessions#login', via: %i[post get]
    match '/register', to: 'sessions#register', via: %i[post get]
    match '/recover-account', to: 'sessions#recover_account', via: :get
    match '/confirm-email', to: 'sessions#confirm_email', via: :get
    match '/request-password-reset', to: 'sessions#request_password_reset', via: :get
    match '/logout', to: 'sessions#logout', via: :all
    match '/contact', to: 'welcome#contact', via: :post 

    resource :profile, only: %i[show index] do
      match :user, on: :collection, via: %i[get put]
      match :account, on: :collection, via: %i[get put]
      match :dietary_preferences, on: :collection, via: %i[get put]
      match :notifications, on: :collection, via: %i[get]
    end

    resource :basket

    resources :allergens, only: %i[index show] do
      get :search, on: :collection
    end

    resources :products do
      patch :add_to_favorites, on: :member
      patch :remove_from_favorites, on: :member
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
      post 'posts/:id/report', to: 'posts#report'
      post 'posts/:post_id/rating', to: 'ratings#create'
      delete 'posts/:post_id/rating', to: 'ratings#destroy'
      resources :users, only: %i[show] do
        get '/follow', to: 'users#follow'
        get '/followers', to: 'users#followers'
        get '/following', to: 'users#following'
      end
    end
  end

  scope module: 'admin', constraints: ->(req) { Context.get_context(req) == :admin }, name_path: 'admin', as: 'admin' do
    root to: 'submissions#index'
    match '/', to: 'welcome#index', via: :all

    match '/login', to: 'sessions#login', via: %i[post get]
    match '/logout', to: 'sessions#logout', via: %i[post]

    resources :submissions
    resources :posts do
      delete :ignore_post, on: :member
      delete :cleanse_reports, on: :member
    end

    resources :products do
      put :approve, on: :member
      put :reject, on: :member
    end

    resources :feedback_messages, only: %i[index] do
      patch :mark_as_read, on: :member
    end
  end
end
