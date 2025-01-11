class UpdateOverdueBorrowingsJob < ApplicationJob
  queue_as :default

  def perform
    # Update overdue records
    Borrowing.where("due_date < ? AND status = ?", Date.today, "borrowed").update_all(status: "overdue")
  end
end
