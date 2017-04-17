Rails.application.routes.draw do
  get 'users/index'

  post 'scrape' => 'scrape#scrape'
  get 'scrape/index'
  get 'scrape/ameblo'
  get 'scrape/instagram'
  get 'scrape/twitter'
  get 'scrape/official_site'
  get 'scrape/news_site'
  get 'scrape/youtube'

  devise_for :users, controllers: { :omniauth_callbacks => 'omniauth_callbacks' }
  get 'users' => 'users#index'
  post 'users/approve' => 'users#approve'
  root 'top_page#index'
  get 'toppage' => 'top_page#show'

  resources :videos, constraints: { id: /\d+/ }, only: [ :index, :edit, :show ]
  get 'videos/tmp'
  get 'videos/search'
  get 'videos/destroy_index'
  post 'videos/multiple'
  resources :pictures, constraints: { id: /\d+/ }, only: [ :index, :edit, :show ]
  get 'pictures/tmp'
  get 'pictures/search'
  get 'pictures/destroy_index'
  post 'pictures/multiple'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  get 'tweets' => 'tweet#index'
end
