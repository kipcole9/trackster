namespace :trackster do
  desc "Import log for web analytics"
  task(:analyse_log => :environment) do
    Rails.logger.info "Starting import of tracking log."    
    if Rails.env == "development"
      Track.delete_all
      Session.delete_all
      Event.delete_all
      $RUNNING = true
      log_tailer = LogAnalyserDaemon.new
      log_tailer.log_analyser_loop :return_if_eof => true
    else
      log_tailer = LogAnalyserDaemon.new      
      log_tailer.log_analyser_loop
    end
  end
  
  
end