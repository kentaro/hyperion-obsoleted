Hyperion::Application.routes.draw do
  resources :roles

  root :to => 'services#index'

  resources :services, constraints: { id: /[^\/]+/ }
  resources :hosts,    constraints: { id: /[^\/]+/ } do
    member do
      get 'graph'
    end
  end
end
