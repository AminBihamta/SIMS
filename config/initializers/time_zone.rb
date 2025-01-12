
Rails.application.configure do
  config.time_zone = 'Asia/Jakarta' # or your appropriate timezone
  config.active_record.default_timezone = :local
end