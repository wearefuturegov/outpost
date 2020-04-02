Rails.application.routes.draw do
  
  root "admin/services#index"

  namespace :admin do
    root "services#index"
    resources :services, except: :edit
  end

  namespace :api do
    namespace :v1 do
      resources :services, only: [:show, :index]
    end
  end
end
