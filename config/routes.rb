Hyperion::Application.routes.draw do
  root :to => 'services#index'

  resources :services, constraints: { id: /[^\/]+/ }
  resources :hosts,    constraints: { id: /[^\/]+/ } do
    member do
      get 'graph'
    end
  end
  resources :roles

  match '/signin' => redirect('/auth/github')
  match '/signout', to: 'sessions#destroy', via: :delete
  match '/auth/:provider/callback', to: 'sessions#create'
end
