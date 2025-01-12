class UpdateOverdueBorrowingsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting UpdateOverdueBorrowingsJob at #{Time.current}"
    
    overdue_borrowings = Borrowing.needs_overdue_update
    count = overdue_borrowings.update_all(
      status: 'overdue',
      updated_at: Time.current
    )
    
    Rails.logger.info "Updated #{count} borrowings to overdue status"
  rescue => e
    Rails.logger.error "Error in UpdateOverdueBorrowingsJob: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end
end