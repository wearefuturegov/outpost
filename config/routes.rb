Rails.application.routes.draw do
  
  root "organisations#index"

  use_doorkeeper
  devise_for :users, :controllers => { registrations: 'registrations' }
  devise_scope :user do
    get "login", to: "devise/sessions#new"
    get "register", to: "devise/registrations#new"
  end
  
  # community users
  resources :organisations, only: [:index, :new, :create, :edit, :update]
  resources :services, except: [:index] do
    post "confirmation", to: "services#confirmation"
    resources :feedback, only: [:index, :create]
  end
  resources :members, only: [:new, :create, :destroy]

  # admin users
  namespace :admin do
    root "dashboard#index"
    resources :services, except: :edit do
      resources :watch, only: [:create, :destroy]
      resources :notes, only: [:create, :destroy]
      resources :snapshots, only: [:index]
      collection do 
        resources :archive, only: [:update]
        resources :requests, only: [:index, :update]
      end
    end
    resources :organisations, except: :edit do
      get "timetable", to: "organisations#timetable"
    end
    resources :labels, only: [:index, :destroy]
    resources :locations, except: [:edit, :new, :create]
    resources :taxonomies, except: [:new, :edit]
    resources :feedbacks, only: [:index]
    resources :ofsted, only: [:index, :show] do
      put "dismiss"
      get "versions"
      collection do
        get "pending"
        get "archive"
      end
    end
    resources :activity, only: [:index, :show]
    resources :custom_fields, except: :edit
    resources :users, except: [:edit] do
      post "reset"
      post "reactivate"
    end
  end

  # api
  namespace :api do
    namespace :v1 do
      resources :taxonomies, only: [:index]
      get "me", to: "me#show"
    end
  end

end