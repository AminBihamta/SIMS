# config/schedule.rb

# Set the output log file for Cron jobs
set :output, "log/cron.log"

# Schedule the job to run every day at midnight
every 1.day, at: "12:00 am" do
  runner "UpdateOverdueBorrowingsJob.perform_now"
end
