Rails.application.routes.draw do
  resources :videos
  resources :pictures
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  get '/tweets' => 'tweet#index'
end
