module Trackster
  DEFAULT_LOGFILE = "#{Trackster::Config.analytics_logfile_directory}/log_analyser.log" rescue nil
  
  class Tlog < Logger
    def format_message(severity, timestamp, progname, msg)
      "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n" 
    end 
  end
  
  class Logger
    def self.logger_instance
      return @@logger if defined?(@@logger)
      @@logfile ||= DEFAULT_LOGFILE
      @@logger ||= @@logfile ? Trackster::Tlog.new(@@logfile, 1) : Rails.logger
    end
          
    def self.info(*args)
      logger_instance.info(*args)
    end
    
    def self.debug(*args)
      logger_instance.info(*args)
    end
    
    def self.warn(*args)
      logger_instance.warn(*args)
    end
    
    def self.error(*args)
      logger_instance.error(*args)
    end
  end
end
