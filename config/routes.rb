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
  
  # https://trello.com/c/aFtIf3QZ/242-prevent-community-users-from-managing-users-in-their-organisation
  # resources :members, only: [:new, :create, :destroy]

  # admin users
  namespace :admin do
    root "dashboard#index"
    resources :services, except: :edit do
      resources :watch, only: [:create, :destroy]
      resources :notes, only: [:create, :destroy]
      resources :versions, only: [:index]
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
      end
    end
    resources :activity, only: [:index, :show]
    resources :custom_field_sections, except: [:edit]
    resources :users, except: [:edit] do
      post :reset, on: :member
      put :reactivate, on: :member
    end
    resource :settings, only: [:edit, :update]
    resources :send_needs, except: [:edit, :show, :destroy, :update] do
      collection do
        post 'create_defaults', to: "send_needs#create_defaults"
      end
    end
  end

  # api
  namespace :api do
    namespace :v1 do
      resources :taxonomies, only: [:index]
      resources :send_needs, only: [:index]
      resources :suitabilities, only: [:index]
      resources :accessibilities, only: [:index]
      get "me", to: "me#show"
      resources :services, only: [:index, :show]
    end
  end

end
