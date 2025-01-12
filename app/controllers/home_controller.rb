class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  
  def index
    @email = current_user # This will show the user's ID from Supabase
    if current_user.nil?
      redirect_to signin_path, alert: "Please sign in to continue"
    elsif session[:user_type]
      redirect_to supervisor_dashboard_path
    else
      redirect_to pic_dashboard_path
    end
  end
end
