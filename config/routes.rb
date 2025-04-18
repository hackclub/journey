Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Root path is landing page for unauthenticated, redirects to dashboard for authenticated
  root "landing#index"

  # Authentication routes
  get "/auth/slack", to: "sessions#new"
  get "/auth/slack/callback", to: "sessions#create", as: :slack_callback
  get "/auth/failure", to: "sessions#failure"
  delete "/logout", to: "sessions#destroy", as: :logout

  # Dashboard
  # get "dashboard", to: "dashboard#index"

  get "explore", to: "projects#index"
  get "activity", to: "projects#activity"
  get "my_projects", to: "projects#my_projects"

  resources :projects do
    resources :updates, only: [ :create, :destroy ]
    member do
      post :follow
      delete :unfollow
    end
  end

  get "updates", to: "updates#index"
  resources :votes, only: [ :new, :create ]

  # api stuff ooooh
  get "api/check_user", to: "users#check_user"
  post "api/updates", to: "updates#api_create"

  # HTTP Error Routes
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
  match "/422", to: "errors#unprocessable_entity", via: :all
  match "/400", to: "errors#bad_request", via: :all

  resources :attachments, only: [] do
    collection do
      post :upload
      get :download
    end
  end

  resources :updates do
    resources :comments, only: [:create, :destroy]
  end
end
