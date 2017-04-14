Rails.application.routes.draw do
  post 'scrape' => 'scrape#scrape'
  get 'scrape/index'
  get 'scrape/ameblo'
  get 'scrape/instagram'
  get 'scrape/twitter'
  get 'scrape/official_site'
  get 'scrape/news_site'
  get 'scrape/youtube'

  devise_for :users, controllers: { :omniauth_callbacks => 'omniauth_callbacks' }
  root 'top_page#index'
  get 'toppage' => 'top_page#show'

  resources :videos, constraints: { id: /\d+/ }
  resources :pictures, constraints: { id: /\d+/ }
  get 'pictures/tmp'
  get 'pictures/search'
  get 'pictures/destroy_index'
  post 'pictures/multiple'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  get 'tweets' => 'tweet#index'
end
