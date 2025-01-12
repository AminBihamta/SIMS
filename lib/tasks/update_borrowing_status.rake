namespace :borrowings do
  desc "Update overdue borrowings and generate notifications"
  task process_overdue: :environment do
    puts "Starting borrowings processing at #{Time.current}"
    
    # First update overdue status
    UpdateOverdueBorrowingsJob.perform_now
    
    # Then generate notifications for newly overdue borrowings
    GenerateNotificationJob.perform_now
    
    puts "Finished borrowings processing at #{Time.current}"
  end
end