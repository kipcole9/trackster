module Daemons
  module AnalyserSupport
    Signal.trap("TERM") do
      logger.info "[Log analyser daemon] Termination requested (TERM signal received); terminating."  
      $RUNNING = false
    end

    Signal.trap("CONT") do
      # The runit environment sends CONT signals as part of the restart and termination
      # process but apart from trapping it here it has no value to us.
      # logger.info "[Log analyser daemon] #{env_cap}: restart requested (CONT signal received)."  
    end

    Signal.trap("HUP") do
      logger.info "[Log analyser daemon] Reconfigure requested (HUP signal) but that's not yet available."  
    end

    class TracksterLogger < Logger
      def format_message(severity, timestamp, progname, msg)
        "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n" 
      end 
    end

    def logger
      return @logger if defined?(@logger)
      logfile = "#{Trackster::Config.analytics_logfile_directory}/log_analyser.log" if Trackster::Config.analytics_logfile_directory  
      @logger ||= Rails.logger # => maybe do this later. logfile ? TracksterLogger.new(logfile, 1) : Rails.logger
    end

    # TODO - get these out of here - and finish implementation properly
    def extract_internal_search_terms!(row, session, web_analyser)
      return unless session.property && (search_param = session.property.search_parameter)
      internal_search = internal_search_terms(search_param, row[:url], web_analyser)
      row[:internal_search_terms] = internal_search if internal_search
    end

    def internal_search_terms
      return nil   # Until we get this fixed
    end
    #def internal_search_terms(search_param, url, web_analyser)
    #  web_analyser.parse_url_parameters(url)[search_param]
    #end

    def last_logged_entry
      return @last_logged_entry if defined?(@last_logged_entry)
      @last_logged_entry = (last_event = Event.last) ? last_event.tracked_at : (Time.now - 10.years)
    end
    
    # Store the event data in the database
    def serialize_event(track)
      begin
        Session.transaction do
          if session = Session.find_or_create_from_track(track)
            session.save! if session.new_record?
            # extract_internal_search_terms!(track, session, web_analyser)
            if event = Event.create_from_track(session, track)
              event.save! 
              session.update_viewcount!
            else
              logger.error "[Log Analyser] Event could not be created. URL: #{track.url}"
            end
          else
            logger.error "[Log Analyser] Sesssion was not found or created. Unknown web property? URL: #{track.url}"
          end
        end
      rescue Mysql::Error => e
        logger.warn "[Log Analyser] Database could not save this data: #{e.message}"
        logger.warn track.inspect
      rescue ActiveRecord::RecordInvalid => e
        logger.error "[Log Analyser] Invalid record detected: #{e.message}"
        logger.error track.inspect
      end
    end
  end
end