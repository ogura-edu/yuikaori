Rails.application.routes.draw do
  devise_for :users, controllers: { :omniauth_callbacks => 'omniauth_callbacks' }
  root 'top_page#index'
  get 'toppage' => 'top_page#show'

  resources :videos, constraints: { id: /\d+/ }
  resources :pictures, constraints: { id: /\d+/ }
  get 'pictures/destroy_index'
  post 'pictures/multiple_destroy'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  get 'tweets' => 'tweet#index'
end
