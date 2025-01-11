Rails.application.routes.draw do
  get "reports/index"
  resources :borrowings do
    collection do
      get :super_club_borrowings
      get :sub_club_borrowings
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  resources :borrowings
  get "up" => "rails/health#show", as: :rails_health_check
  get "equipments/group/:equipment_name", to: "equipments#group_items", as: :group_items

  resources :equipments
  resources :vendors
  get "/signin", to: "auth#signin_new"
  post "/signin", to: "auth#sign_in"
  delete "/signout", to: "auth#sign_out"

  resources :clubs do
    member do
      get :show_children
    end
    collection do
      get :new_super_club
      get :new_sub_club
    end
  end

  get "/reports", to: "reports#index"
  get "/reports/generate", to: "reports#generate", as: :generate_reports
  get "/clubs/:id/sub_clubs", to: "clubs#sub_clubs"


  # Define the route for club_created
  get "club_created", to: "clubs#club_created", as: :club_created

  # Set the root route to the sign-in page
  root to: "auth#signin_new"
end
