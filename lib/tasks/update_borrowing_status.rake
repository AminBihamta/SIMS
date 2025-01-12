namespace :borrowings do
  desc "Update overdue borrowings and generate notifications"
  task update_overdue: :environment do
    puts "Starting borrowings processing at #{Time.current}"
    
    Borrowing.transaction do
      overdue_count = Borrowing.needs_overdue_update
                              .update_all(status: 'overdue', updated_at: Time.current)
      puts "Updated #{overdue_count} borrowings to overdue status"
    end

    GenerateNotificationJob.perform_now
    puts "Finished borrowings processing at #{Time.current}"
  end
end