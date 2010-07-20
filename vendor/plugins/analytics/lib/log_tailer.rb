# Tail the end of a log file and pass the record to the provided block.
# Takes care of log rotation, end of file waiting and so on
require 'file/tail'

class LogTailer
  attr_accessor :log_inode, :logger, :log

  def initialize(options = {})
    # Configuration options
    @logger          = Trackster::Logger
    @options         = options
    @nginx_log_dir   = Trackster::Config.nginx_logfile_directory
  end

  def tail(options = {}, &block)
    raise ArgumentError, "LogTailer.tail requires a block" unless block_given?
    default_options = {:forward => 0}
    options     = default_options.merge(@options).merge(options) 
    @log        = File::Tail::Logfile.open(log_file, options)
    @log_inode  = File.stat(log_file).ino
    log.interval            = 1     # Initial sleep interval when no data
    log.max_interval        = 5     # Maximum sleep interval when no data.
    log.reopen_deleted      = true  # is default
    log.reopen_suspicious   = true  # is default
    log.suspicious_interval = 20    # When several loops of no data - like when logs rotated
    
    logger.info "[Log Tailer] Log tail loop is beginning."
    
    # Is called by log tailer when the log file is reopened (which happens after a series
    # of EOF detections)
    log.after_reopen do
      if running?
        # logger.debug "[Log analyser daemon] Log analyser has reopened #{log_file}"
        check_if_log_was_rotated
      else
        logger.info "[Log Tailer] Log tailer is terminating as requested (detected after log reopen)"
        log.close
        return
      end
    end
    
    # Main log loop
    log.tail do |line|
      if running?
        yield line
      else
        logger.info "[Log Tailer] Log tailer is terminating as requested (there may be unprocessed log entries)"
        log.close
        return
      end   
    end
  end 

  def running?
    $RUNNING
  end
  
  def terminating?
    !running?
  end
  
private
  def log_file
    # The log file we're importing.  Implies knowledge of the deployment strategy and development
    # environment.
    @log_file ||= case Rails.env
      when "development"
        "#{Rails.root}/tmp/tracker_access_production.log"
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
      logger.info "[Log Tailer] Log tailer has detected a probable log rotation and moved to new logfile."
      log.forward
      @log_inode = new_file_inode
    end
  end
  
end