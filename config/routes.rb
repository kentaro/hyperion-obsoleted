Hyperion::Application.routes.draw do
  root :to => 'services#index'

  resources :services
  resources :hosts
end
