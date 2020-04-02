Rails.application.routes.draw do

  root "admin/services#index"

  namespace :admin do
    resources :services
  end

  namespace :api do
    namespace :v1 do
      resources :services, only: [:show, :index]
    end
  end
end
