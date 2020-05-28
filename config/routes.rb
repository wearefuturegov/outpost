Rails.application.routes.draw do
  
  root "organisations#index"

  devise_for :users, :controllers => { registrations: 'registrations' }
  devise_scope :user do
    get "login", to: "devise/sessions#new"
    get "register", to: "devise/registrations#new"
  end
  
  resources :organisations, only: [:index, :new, :create, :edit, :update]
  resources :services, except: [:edit] do
    get "feedback", to: "feedbacks#index"
    post "feedback", to: "feedbacks#create"
  end
  resources :members, only: [:new, :create, :destroy]


  namespace :admin do
    root "dashboard#index"
    resources :services, except: :edit do
      resources :watch, only: [:create, :destroy]
      resources :notes, only: [:create, :destroy]
      resources :snapshots, only: [:index, :show, :update]
      collection do 
        resources :archive, only: [:update]
        resources :requests, only: [:index, :update]
      end
    end
    resources :organisations, except: :edit
    resources :labels, only: [:index, :destroy]
    resources :locations, except: [:edit, :new, :create]
    resources :taxonomies, except: [:new, :edit]
    resources :feedbacks, only: [:index]
    resources :ofsted, only: [:index, :show] do
      collection do
        get "pending"
      end
    end
    resources :activity, only: [:index]
    resources :users, except: [:edit] do
      post "reset"
      post "reactivate"
    end
  end

  namespace :api do
    namespace :v1 do
      resources :services, only: [:show, :index]
      resources :taxonomies, only: [:index]
    end
  end

end
