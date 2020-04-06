Rails.application.routes.draw do
  
  root "admin/services#index"

  devise_for :users
  
  namespace :admin do
    root "services#index"
    resources :services, except: :edit do
      member do
        post "watch"
        delete "unwatch"
      end
    end
    resources :users, except: [:edit, :show]
  end

  namespace :api do
    namespace :v1 do
      resources :services, only: [:show, :index]
    end
  end
end
