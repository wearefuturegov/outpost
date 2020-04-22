Rails.application.routes.draw do
  
  root "organisations#index"

  devise_for :users
  resources :organisations, only: [:index, :new, :create, :edit, :update] do
    collection do
      get "start"
    end
  end
  resources :services, only: [:new, :create, :show, :update]
  resources :members, only: [:new, :create]

  namespace :admin do
    root "dashboard#index"
    resources :services, except: :edit do
      resources :watch, only: [:create, :destroy]
      resources :notes, only: [:create, :destroy]
      resources :versions, only: [:index, :update]
      collection do 
        resources :archive, only: [:index, :update]
        resources :requests, only: [:index, :update]
      end
    end
    resources :organisations, except: :edit
    resources :locations, except: :edit
    resources :taxonomies, except: [:new, :edit]
    resources :activity, only: [:index]
    resources :users, except: [:edit]
  end

  namespace :api do
    namespace :v1 do
      resources :services, only: [:show, :index]
    end
  end
end
