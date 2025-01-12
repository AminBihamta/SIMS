class SupervisorController < ApplicationController
  before_action :authenticate_user!
  before_action :require_supervisor!

  def dashboard
    flash[:success] = "Welcome supervisor."

    # Fetch all borrowings along with related data
    @borrowings = Borrowing.includes(:equipment, :club).all

    # Fetch PICs for clubs from user_data
    @pic_data = UserData.where(is_supervisor: false).group_by(&:club_id)

    render "auth/supervisor/dashboard"
  end
end