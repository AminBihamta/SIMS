class SupervisorController < ApplicationController
  before_action :authenticate_user!
  before_action :require_supervisor!

  def dashboard
    flash[:success] = "Welcome supervisor."
    render "auth/supervisor/dashboard"
  end
end
