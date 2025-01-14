module BorrowingsHelper
  def overdue_borrowings
    Borrowing.where(status: "overdue")
  end
end
