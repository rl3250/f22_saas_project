Rottenpotatoes::Application.routes.draw do
  resources :users, only: [:new, :create]
   get 'login', to: 'sessions#new', as: 'sign_up'
   post 'login', to: 'sessions#create', as: 'log_in'
   get 'welcome', to: 'sessions#welcome', as: "login_signup"
   get 'authorized', to: 'sessions#page_requires_login'
   get 'logout', to: 'sessions#logout', as: 'logout'

  resources :events do
    resources :comments, except: ['show']
  end 
  
  # map '/' to be a redirect to '/events'
  root :to => redirect('/welcome')
  
  match '/myEvents', to: 'events#myEvents', as: 'myEvents', via: :get 
  match '/search_result', to: 'events#index', as: 'search_result', via: :get
  match '/join', to: 'events#join', as: 'join', via: :get
  match '/events/:id/ratePeople', to: 'events#ratePeople', as: 'rate', via: :get
  match '/events/:id/rateUser', to: 'users#rateUser', as: 'rate_user', via: :put

  get '/auth/:provider/callback' => 'sessions#omniauth'
end
