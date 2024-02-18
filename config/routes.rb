Rails.application.routes.draw do
  scope module: 'user', constraints: ->(req) { Context.get_context(req) == :user } do
    match '/', to: 'welcome#index', via: :all

  end
end
