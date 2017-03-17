Rails.application.routes.draw do
  resources :videos
  resources :pictures
  get '/index_destroy' => 'pictures#index_destroy'
  post '/multiple_destroy' => 'pictures#multiple_destroy'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  get '/tweets' => 'tweet#index'
end
