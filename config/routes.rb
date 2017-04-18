Rails.application.routes.draw do
  root 'top_page#index'
  
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }, skip: :sessions
  devise_scope :user do
    delete 'users/logout', to: 'users/sessions#destroy'
    delete 'users/destroy', to: 'users/registrations#destroy'
    get 'users/index', to: 'users/admin#index'
    post 'users/approve', to: 'users/admin#approve'
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
