Rails.application.routes.draw do
  resources :players, except: [:show]
  resources :packs, only: [:index, :new, :create, :destroy]

  resources :minecraft_servers do
    member do
      post :start
      post :stop
      post :restart
      get :logs
      post :assign_pack
      delete :unassign_pack
    end
  end

  root "minecraft_servers#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
