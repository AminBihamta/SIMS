# filepath: /Users/aminbihamta/Software Engineering/SIMS/app/controllers/reports_controller.rb
class ReportsController < ApplicationController
  def index
  end

  def generate
    @super_club = Club.find(params[:super_club_id])
    @sub_club = Club.find_by(Club_ID: params[:sub_club_id])
    @start_date = params[:start_date]
    @end_date = params[:end_date]

    # Fetch expenses for the selected sub club within the date range
    @expenses = FinancialRecord.where(Club_ID: @sub_club.Club_ID)
                               .where("created_at >= ? AND created_at <= ?", @start_date, @end_date)

    # Prepare data for the chart
    @chart_data = @expenses.group_by_day(:created_at).sum(:Amount)

    render :generated
  end
end
