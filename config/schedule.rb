set :output, "log/cron.log"

# Run more frequently to catch time-specific overdues
every 1.minute do
  runner "UpdateOverdueBorrowingsJob.perform_now"
end
