Rails.application.routes.draw do
  
  use_doorkeeper
  root "organisations#index"

  devise_for :users, :controllers => { registrations: 'registrations' }
  devise_scope :user do
    get "login", to: "devise/sessions#new"
    get "register", to: "devise/registrations#new"
  end
  
  resources :organisations, only: [:index, :new, :create, :edit, :update]
  resources :services do
    get "feedback", to: "feedbacks#index"
    post "feedback", to: "feedbacks#create"
  end
  resources :members, only: [:new, :create, :destroy]

  namespace :admin do
    root "dashboard#index"
    resources :services, except: :edit do
      resources :watch, only: [:create, :destroy]
      resources :notes, only: [:create, :destroy]
      resources :snapshots, only: [:index, :update]
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

  namespace :api do
    namespace :v1 do
      resources :taxonomies, only: [:index]
    end
  end

end
