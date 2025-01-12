class PicController < ApplicationController
  before_action :require_pic!

  def dashboard
    @club_id = session[:club_id]

    # First get the club's borrowings that are overdue
    overdue_borrowings = Borrowing.where(
      club_id: @club_id,
      status: "overdue"
    )

    # Then get notifications for these borrowings
    @notifications = Notification.joins(:borrowing)
                               .where(borrowing_id: overdue_borrowings.pluck(:id))
                               .order(created_at: :desc)
                               .limit(2)

    # Fetch latest borrowings
    @borrowings = Borrowing.includes(:equipment)
                          .where(club_id: @club_id)
                          .order(created_at: :desc)
                          .limit(6)

    render "auth/PIC/dashboard"
  end

  def borrowed_items
    @club_id = session[:club_id]

    # Fetch all borrowings for the club
    @borrowed_items = Borrowing.where(club_id: @club_id).includes(:equipment).order(created_at: :desc)

    render "auth/PIC/borrowed_items"
  end

  def balance_sheet
    @club_id = session[:club_id]
    
    # Date range filter
    range = params[:date_range] || '1-month'
    start_date = case range
      when '1-month'
        1.month.ago
      when '6-months'
        6.months.ago
      when '1-year'
        1.year.ago
      else
        100.years.ago # effectively all records
      end

    @financial_records = FinancialRecord
      .where(Club_ID: @club_id)
      .where('Created_At >= ?', start_date)
      .includes(:equipment)
      .order(created_at: :desc)

    # Calculate total expenses for the selected period
    @total_expenses = @financial_records.sum(:Amount)

    render "auth/PIC/balance_sheet"
  end
end
