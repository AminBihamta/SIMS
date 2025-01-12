env :PATH, ENV['PATH']
env :GEM_PATH, ENV['GEM_PATH']
set :environment, 'development'
set :output, "/mnt/c/Users/MALIHA/SIMS/SIMS/log/cron.log"
set :job_template, "bash -l -c ':job'"

every 1.minute do
  rake "borrowings:update_overdue"
end