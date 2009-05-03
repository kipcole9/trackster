namespace :trackster do

  desc "Import log for web analytics"
  task(:analyse_log => :environment) do
    require 'log_tailer'
    if Rails.env == "development"
      Track.delete_all
      Session.delete_all
      Event.delete_all
      log_file = ENV["log"] || "#{RAILS_ROOT}/tmp/test_data/track_data"
      Rails.logger.info "Starting import of tracking log '#{log_file}'."
      log_tailer log_file, :return_if_eof => true
    else
      log_file = ENV["log"] || "/usr/local/nginx/logs/tracking_log"
      Rails.logger.info "Starting import of tracking log '#{log_file}'."
      log_tailer log_file
    end
  end
  
  
end