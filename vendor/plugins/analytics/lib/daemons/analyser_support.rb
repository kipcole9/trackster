module Daemons
  module AnalyserSupport
    class Trackster::InvalidSession < Exception; end
    class Trackster::InvalidEvent < Exception; end
    
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

    def logger
      Trackster::Logger
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

  end
end