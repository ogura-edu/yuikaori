Rails.application.routes.draw do
  root 'top_page#index'
  
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }, skip: :sessions
  devise_scope :user do
    delete 'users/logout', to: 'users/sessions#destroy'
    delete 'users/destroy', to: 'users/registrations#destroy'
    get 'users/index', to: 'users/admin#index'
    patch 'users/approve', to: 'users/admin#approve'
    patch 'users/admin', to: 'users/admin#admin'
  end

  post :scrape, to: 'scrape#scrape'
  namespace :scrape do
    get :index
    get :ameblo
    get :instagram
    get :twitter
    get :official_site
    get :news_site
    get :youtube
  end

  resources :media_contents, constraints: { id: /\d+/ }, only: [ :index, :edit, :show, :update ] do
    collection do
      get :tmp
      patch :tmp, to: 'media_contents#multiple'
      get :deletion_request
      patch :deletion_request, to: 'media_contents#hide'
      get :search
    end
  end
  
  get 'tweets' => 'tweet#index'
end
