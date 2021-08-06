Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations" }
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :trips
  get '/your_trip', to: 'trips#your_trip', as: :your_trip

  resources :categories
  resources :activities

  get '/components', to: 'pages#components', as: :components

end
