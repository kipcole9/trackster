    # Main method for decoding a log file entry for its analytics content.
    # This method will create the Track, Session and Event objects and serialise
    # them to the database.  Feed a parsed row from a log file to this
    # method to save analytics data to the database. See log_tailer.rb for
    # the most relevant usage example or the method #parse_log above.
    # option[:geocode] if true will geocode the data.  You most likely want this to
    # be true since we are now resolving this data from the hostip.info database
    # locally (no net latency).
    def save_web_analytics!(web_analyser, entry, options = {})
      unless row = web_analyser.create(entry)
        logger.error "[log_parser] Row could not be created from log data:"
        logger.error entry.inspect
        return nil
      end
    
      Session.transaction do
        if session = Session.find_or_create_from_track(row)
          session.save! if session.new_record?
          extract_internal_search_terms!(row, session, web_analyser)
          if event = Event.create_from_row(session, row)
            event.save! 
            session.update_viewcount!
          else
            logger.error "[log_parser] Event could not be created. URL: #{row[:url]}"
          end
        else
          logger.error "[log_parser] Sesssion was not found or created. Unknown web property? URL: #{row[:url]}"
        end
      end
    rescue Mysql::Error => e
      logger.warn "[log_parser] Database could not save this data: #{e.message}"
      logger.warn row.inspect
    rescue ActiveRecord::RecordInvalid => e
      logger.error "[log_parser] Invalid record detected: #{e.message}"
      logger.error row.inspect
    end    

  private
  
    def extract_internal_search_terms!(row, session, web_analyser)
      return unless session.property && (search_param = session.property.search_parameter)
      internal_search = internal_search_terms(search_param, row[:url], web_analyser)
      row[:internal_search_terms] = internal_search if internal_search
    end
  
    def internal_search_terms(search_param, url, web_analyser)
      web_analyser.parse_url_parameters(url)[search_param]
    end

  end
end