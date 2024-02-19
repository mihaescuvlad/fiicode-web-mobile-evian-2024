Rails.application.routes.draw do
  scope module: 'user', constraints: ->(req) { Context.get_context(req) == :user } do
    root to: 'welcome#index'
    match '/', to: 'welcome#index', via: :all
    get '/login', to: 'sessions#login'
    get '/register', to: 'sessions#register'
  end
end
