Rails.application.routes.draw do

  namespace :admin do
    resources :services
  end

  namespace :api do
    namespace :v1 do
      resources :services, only: [:show, :index]
    end
  end
end
