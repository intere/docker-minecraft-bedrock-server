Rails.application.routes.draw do
  resources :minecraft_servers do
    member do
      post :start
      post :stop
      post :restart
      get :logs
    end
  end

  root "minecraft_servers#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
