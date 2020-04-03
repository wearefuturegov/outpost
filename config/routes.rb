Rails.application.routes.draw do
  
  root "admin/services#index"

  devise_for :users
  
  namespace :admin do
    root "services#index"
    resources :services, except: :edit do
      member do
        post 'watch'
      end
    end
    resources :users, only: [:index]
  end

  namespace :api do
    namespace :v1 do
      resources :services, only: [:show, :index]
    end
  end
end
