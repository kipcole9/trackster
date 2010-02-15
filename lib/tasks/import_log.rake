# Convenience task that should be used in development only.
# The LogAnalyserDaemon object handles this in staging
# or production.
namespace :trackster do
  desc "Import log for web analytics"
  task(:analyse_log => :environment) do
    require 'analytics/log_analyser_daemon'
    Rails.logger.info "Starting import of tracking log."    
    if Rails.env == "development"
      #Session.delete_all
      #Event.delete_all
      $RUNNING = true
      log_tailer = LogAnalyserDaemon.new
      log_tailer.log_analyser_loop :return_if_eof => true
    else
      log_tailer = LogAnalyserDaemon.new      
      log_tailer.log_analyser_loop
    end
  end
  
  desc "Get staging tracker log file from traphos"
  task(:get_staging_log => :environment) do
    `scp -P 9876 kip@traphos.com:/opt/nginx/logs/tracker_access_staging.log tmp/`
  end

  desc "Get production tracker log file from traphos"
  task(:get_production_log => :environment) do
    `scp -P 9876 kip@traphos.com:/opt/nginx/logs/tracker_access_production.log tmp/`
  end
end