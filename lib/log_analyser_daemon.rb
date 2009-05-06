class LogAnalyserDaemon
  # Check that a log entry matches a logging record
  TRACK_PATTERN = /\A\/_tks.gif\/?/
  
  def initialize(options = {})
    # Configuration options
    @options         = {:forward => 0}
    @log_parser      = LogParser.new(:nginx)
    @web_analyser    = WebAnalytics.new
    @last_log_entry  = [(Event.maximum(:tracked_at) || Time.at(0)), (Session.maximum(:ended_at) || Time.at(0))].max
    @nginx_log_dir   = '/usr/local/nginx/logs'
  end
  
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
  
  def log_analyser_loop
    log = File.open(log_file)
    log.extend(File::Tail)
    log.interval            = 1     # Initial sleep interval when no data
    log.max_interval        = 5     # Maximum sleep interval when no data
    log.reopen_deleted      = true  # is default
    log.reopen_suspicious   = true  # is default
    log.suspicious_interval = 20    # When several loops of no data - like when logs rotated
    
    log.after_reopen do
      if running?
        ActiveRecord::Base.logger.info "Log analyser has reopened #{log_file}"
      else
        ActiveRecord::Base.logger.info "Log analyser is terminating"
        log.close
        return
      end
    end
    
    log.tail do |line|  
      return unless running?  
      entry = @log_parser.parse_entry(line)
      if entry[:datetime] > @last_log_entry && entry[:url] =~ TRACK_PATTERN
        @log_parser.save_web_analytics!(@web_analyser, entry) unless @web_analyser.is_crawler?(entry[:user_agent])
      end
    end
  end 

  def running?
    $RUNNING
  end

end