Hyperion::Application.routes.draw do
  root :to => 'services#index'

  resources :hosts,    constraints: { id: /[^\s]+/ }
  resources :services, constraints: { id: /[^\s]+/ }
end
