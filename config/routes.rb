Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations" }
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :trips
  get '/trips/days/:id', to: 'trips#day', as: :day_trip
  get '/your_trip', to: 'trips#your_trip', as: :your_trip
  get '/your_trip/next', to: 'trips#next', as: :next_day
  get '/your_trip/prev', to: 'trips#prev', as: :prev_day
  get '/about', to: 'pages#about', as: :about
  resources :categories
  resources :activities do
    member do
      patch :assign_day
      patch :remove_day
    end
  end

  get '/components', to: 'pages#components', as: :components

end
