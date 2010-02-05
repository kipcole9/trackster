class LogAnalyserDaemon
  # Check that a log entry matches a logging record
  # First kind is a regular .gif request.
  # The second is a redirect record
  attr_accessor :web_analyser, :log_parser, :log_inode, :last_log_entry
  
  def initialize(options = {})
    # Configuration options
    @options         = options
    @log_parser      = LogParser.new(:nginx)
    @web_analyser    = WebAnalytics.new
    @last_log_entry  = [(Event.maximum(:tracked_at) || Time.at(0)), (Session.maximum(:ended_at) || Time.at(0))].max
    @nginx_log_dir   = Trackster::Config.log_file_directory
  end

  def log_analyser_loop(options = {})
    default_options = {:forward => 0}
    options     = @options.merge(default_options).merge(options) 
    log         = File::Tail::Logfile.open(log_file, options)
    @log_inode  = File.stat(log_file).ino
    log.interval            = 1     # Initial sleep interval when no data
    log.max_interval        = 5     # Maximum sleep interval when no data
    log.reopen_deleted      = true  # is default
    log.reopen_suspicious   = true  # is default
    log.suspicious_interval = 20    # When several loops of no data - like when logs rotated
    
    # Is called by log tailer when the log file is reopened (which happens after a series
    # of EOF detections)
    log.after_reopen do
      if running?
        ActiveRecord::Base.logger.debug "[Log analyser daemon] Log analyser has reopened #{log_file}"
        check_if_log_was_rotated
      else
        ActiveRecord::Base.logger.info "[Log analyser daemon] Log analyser is terminating as requested (after log reopen)"
        log.close
        return
      end
    end
    
    # Main log loop
    log.tail do |line|
      begin
        entry = log_parser.parse_entry(line)
        if entry[:datetime]
          if entry[:datetime] > last_log_entry && web_analyser.is_tracker?(entry[:url]) && !web_analyser.is_crawler?(entry[:user_agent])
            log_parser.save_web_analytics!(web_analyser, entry)
          end
        else
          ActiveRecord::Base.logger.info "[Log analyser daemon] Skipping badly formatted log entry: #{line}"
        end
      rescue ActiveRecord::StatementInvalid => e
        if e.to_s =~ /away/
          ActiveRecord::Base.logger.info "[Log analyser daemon] Recovering from MySql 'gone away' timeout."
          ActiveRecord::Base.connection.reconnect! && retry
        else
          raise e
        end
      end
    end
    
    unless running?
      ActiveRecord::Base.logger.info "[Log analyser daemon] Log analyser is terminating as requested (there may be unprocessed log entries)"
      log.close
      return
    end    
  end 

  def running?
    $RUNNING
  end
  
private
  
  def log_file
    # The log file we're importing.  Implies knowledge of the deployment strategy and development
    # environment.
    @log_file ||= case Rails.env
      when "development"
        "#{Rails.root}/tmp/test_data/track_data"
      when "staging", "production"
        "#{@nginx_log_dir}/tracker_access_#{Rails.env}.log"
      else
        raise ArgumentError, "Unknown rails environment: #{Rails.env}"
      end
  end

  def log_was_rotated?
    (new_file = File.stat(log_file).ino) != @log_inode ? new_file : false
  end
  
  def check_if_log_was_rotated  
    if new_file_inode = log_was_rotated?
      ActiveRecord::Base.logger.debug "[Log analyser daemon] Log analyser has detected a probable log rotation and moved to new logfile."
      log.forward
      @log_inode = new_file_inode
    end
  end

end