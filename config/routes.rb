Rails.application.routes.draw do
  
  root "organisations#index"

  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :organisations, only: [:index, :new, :create, :edit, :update] do
    collection do
      get "start"
    end
  end
  resources :services, except: [:edit]
  resources :members, only: [:new, :create, :destroy]

  namespace :admin do
    root "dashboard#index"
    resources :services, except: :edit do
      resources :watch, only: [:create, :destroy]
      resources :notes, only: [:create, :destroy]
      resources :snapshots, only: [:index, :update]
      collection do 
        resources :archive, only: [:index, :update]
        resources :requests, only: [:index, :update]
      end
    end
    resources :organisations, except: :edit
    resources :locations, except: [:edit, :new, :create]
    resources :taxonomies, except: [:new, :edit]
    resources :activity, only: [:index]
    resources :users, except: [:edit] do
      post "reset"
      post "reactivate"
    end
  end

  namespace :api do
    namespace :v1 do
      resources :services, only: [:show, :index]
    end
  end
end
