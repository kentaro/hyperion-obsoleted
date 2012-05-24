Hyperion::Application.routes.draw do
  root :to => 'services#index'

  resources :hosts,    constraints: { id: /[^\s]+/ }
  resources :services, constraints: { id: /[^\s]+/ }

  match '/graph/:hostname/:plugin/:type' => 'graph#show',
  via: [:get],
  constraints: {
    hostname: /[^\s]+/,
    plugin:   /[^\s]+/,
    type:     /[^\s]+/
  }
end
