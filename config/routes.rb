Hyperion::Application.routes.draw do
  root :to => 'services#index'

  resources :hosts,    constraints: { id: /[\w\-\.]+/ }
  resources :services, constraints: { id: /[\w\-\.]+/ }
end
