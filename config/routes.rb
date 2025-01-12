Rails.application.routes.draw do
    # Auth routes
    get "/signup", to: "auth#new"
    post "/signup", to: "auth#sign_up"
    get "/signin", to: "auth#signin_new"
    post "/signin", to: "auth#sign_in"
    delete "/signout", to: "auth#sign_out"
    get "/signed_in", to: "auth#signed_in"
  
    # Dashboard routes
    get "supervisor/dashboard", to: "supervisor#dashboard", as: :supervisor_dashboard
    get "PIC/dashboard", to: "pic#dashboard", as: :pic_dashboard
    get "PIC/borrowed_items", to: "pic#borrowed_items", as: :pic_borrowed_items
    get "PIC/balance_sheet", to: "pic#balance_sheet", as: :pic_balance_sheet
    
    # Borrowings routes
  resources :borrowings, except: [:show] do
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

  # Equipment Routes
  resources :equipments do
    member do
      get :club_info
    end
  end

  resources :notifications, only: [:index, :show] do
    member do
      post :resend
    end
  end

  resources :borrowings, only: [] do
    member do
      patch :return
    end
  end

  # Set the root route to the sign-in page
  root to: "auth#signin_new"
end
