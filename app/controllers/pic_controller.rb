class PicController < ApplicationController
  before_action :require_pic!

  def dashboard
    @club_id = session[:club_id]


  # Fetch notifications for this PIC
  @notifications = Notification.includes(:borrowing)
  .where(status: "delivered")
  .joins(:borrowing)
  .where(borrowings: { club_id: @club_id })
  .order(created_at: :desc)

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
    range = params[:date_range] || "1-month"
    start_date = case range
    when "1-month"
        1.month.ago
    when "6-months"
        6.months.ago
    when "1-year"
        1.year.ago
    else
        100.years.ago # effectively all records
    end

    @financial_records = FinancialRecord
      .where(Club_ID: @club_id)
      .includes(:equipment)
      .order(Expense_Date: :desc)

# Calculate total expenses for the selected period
#
@total_spent = 0
@financial_records.each do |record|
  @total_spent += record.Amount
end


@total_expenses = @financial_records.sum(:Amount)

    render "auth/PIC/balance_sheet"
  end
end
