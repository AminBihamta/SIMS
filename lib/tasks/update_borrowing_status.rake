namespace :borrowings do
  desc "Update status of overdue borrowings"
  task update_overdue: :environment do
    puts "Starting overdue borrowings update at #{Time.current}"
    UpdateOverdueBorrowingsJob.perform_now
    puts "Finished overdue borrowings update"
  end
end