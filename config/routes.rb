Rails.application.routes.draw do
  devise_for :users
  # Devise authentication
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  # Root route
  root "home#index"

  # Dashboard (requires authentication)
  get "dashboard", to: "home#dashboard", as: :dashboard

  # Routines with collaborative sharing
  resources :routines do
    member do
      post :share
      delete :unshare
    end
    resources :chat_messages, only: [:index, :create], module: :routines
  end

  # Global chat (not routine-specific)
  resources :chat_messages, only: [:index, :create]

  # Subscriptions / Pricing
  resources :subscriptions, only: [:index] do
    collection do
      get :pricing
      post :upgrade
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
