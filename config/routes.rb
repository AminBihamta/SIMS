Rails.application.routes.draw do
    # Auth routes
    get "/signup", to: "auth#new"
    post "/signup", to: "auth#sign_up"
    get "/signin", to: "auth#signin_new"
    post "/signin", to: "auth#sign_in"
    get "/signout", to: "auth#sign_out"
    get "/signed_in", to: "auth#signed_in"

    # Dashboard routes
    get "supervisor/dashboard", to: "supervisor#dashboard", as: :supervisor_dashboard
    get "PIC/dashboard", to: "pic#dashboard", as: :pic_dashboard
    get "PIC/borrowed_items", to: "pic#borrowed_items", as: :pic_borrowed_items
    get "PIC/balance_sheet", to: "pic#balance_sheet", as: :pic_balance_sheet

  # Borrowings routes

  get "reports/index"
  resources :borrowings do
    collection do
      get :super_club_borrowings
      get :sub_club_borrowings
    end
  end



  # Routes for balance sheet and notifications
  get "balance_sheet/:id", to: "borrowings#balance_sheet", as: "borrowing_balance_sheet"
  get "borrowings/notification", to: "borrowings#notification", as: "borrowing_notification"

  # Equipments stock route
  get "/equipments/:id/stock", to: "equipments#stock"



  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  resources :borrowings
  get "up" => "rails/health#show", as: :rails_health_check
  get "equipments/group/:equipment_name", to: "equipments#group_items", as: :group_items

  resources :equipments
  resources :vendors

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


  # Equipment Routes
  resources :equipments do
    member do
      get :club_info
      get 'stock'
    end
  end

  resources :notifications, only: [ :index, :show ] do
    member do
      post :send_to_pic
      post :resend
      post :return_equipment
    end
  end

    patch "/clubs/:id/update_budget", to: "clubs#update_parent_club_budget", as: :update_parent_club_budget

  resources :borrowings, only: [] do
    member do
      patch :return
    end
  end
  # Define the route for club_created
  get "club_created", to: "clubs#club_created", as: :club_created

  # Set the root route to the sign-in page
  root to: "home#index"


    resources :financial_records, only: [ :create, :edit, :update, :index, :show, :destroy ] do
    collection do
      get :expenseForm, as: :expense_form
      get :expenseDashboard
      get :super_club_expenses
      get :sub_club_expenses
    end

    member do
      get :all_super_expenses
      get :all_sub_expenses
      get :expense_details
      get :delete_confirmation
    end
end
end
