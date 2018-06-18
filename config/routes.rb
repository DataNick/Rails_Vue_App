Rails.application.routes.draw do
  resources :cards
  resources :lists do
    member do
      patch :move
    end
  end
  resources :boards
  root to: "lists#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
