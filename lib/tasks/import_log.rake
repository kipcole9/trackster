namespace :caerus do
  
  desc "Import Tracking log file"
  task(:import_log => :environment) do
    #`scp -P 9876 kip@kipcole.com:/usr/local/nginx/logs/track_data public/track_data`
    # Track.delete_all
    LogParser.new.parse_log('/Users/kip/development/rails/caerus/public/track_data')
  end
  
end