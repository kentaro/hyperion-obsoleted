Hyperion::Application.routes.draw do
  root :to => 'services#index'

  resources :services
  resources :hosts, constraints: { id: /[0-9\.]{7,15}/ }
end
