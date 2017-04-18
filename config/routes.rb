Rails.application.routes.draw do
  root 'top_page#index'
  
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }, skip: :sessions
  namespace :users do
    delete :logout, to: 'sessions#destroy'
    get :index, controller: :admin
    post :approve, controller: :admin
  end

  namespace :scrape do
    post :scrape, as: ''
    get :index
    get :ameblo
    get :instagram
    get :twitter
    get :official_site
    get :news_site
    get :youtube
  end


  resources :pictures, :videos, constraints: { id: /\d+/ }, only: [ :index, :edit, :show ] do
    collection do
      get :tmp
      get :search
      get :destroy_index
      post :multiple
    end
  end
  
  get 'tweets' => 'tweet#index'
end
