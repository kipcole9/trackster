module Analytics
  class LogParser
    ATTRIBS = {
      :ip_address     => "(\\S*)",
      :remote         => "(\\S*)",
      :user           => "(\\S*)",
      :time           => "\\[(.+?)\\]",
      :request        => "\"(.+?)\"",
      :status         => "(\\S*)",
      :size           => "(\\S*)",
      :referer        => "\"(.+?)\"",
      :user_agent     => "\"(.+?)\"",
      :forwarded_for  => "\"(.+?)\""
    }
  
    COMMON_LOG = [:ip_address, :remote, :user, :time, :request, :status, :size, :referer, :user_agent, :forwarded_for]
    DATE_FORMAT = '%d/%b/%Y:%H:%M:%S %z'
    attr_accessor   :format, :regexp, :column, :logger
  
    def initialize(options = {})
      if options.empty? || options[:format] == :nginx || options[:format] == :common
        @args = COMMON_LOG
      else
        @args = options[:format]
      end
    
      validate_args!(@args)
      @logger = options[:logger] || Rails.logger
      @formats = []
      @args.each {|arg| @formats << ATTRIBS[arg]}
      @format = "\\A" + @formats.join(' ') + "\\Z"
      @regexp = Regexp.new(@format)
    end
  
    # Parses the incoming log record and breaks it up into the 
    # the relevant attributes in @columns
    def parse_entry(log_entry)
      @column = {}; i = 1;
      if attributes = log_entry.match(regexp)
        @args.each {|f| @column[f] = attributes[i]; i += 1}
        parse_datetime! if @column[:time]
        parse_request! if @column[:request]
      end
      @column
    end

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
    def validate_args!(args)
      args.each {|arg| raise(ArgumentError, "[log_parser] Unknown log attribute ':#{arg}'.") unless ATTRIBS[arg]}
    end
  
    def parse_datetime!
      @column[:datetime] = DateTime.strptime(@column[:time], DATE_FORMAT)
    end
  
    def parse_request!
      parts = @column[:request].split(' ')
      @column[:method] = parts[0]
      @column[:url] = parts[1]
      @column[:protocol] = parts[2]
    end
  
    def extract_internal_search_terms!(row, session, web_analyser)
      return unless search_param = session.property.search_parameter
      internal_search = internal_search_terms(search_param, row[:url], web_analyser)
      row[:internal_search_terms] = internal_search if internal_search
    end
  
    def internal_search_terms(search_param, url, web_analyser)
      web_analyser.parse_url_parameters(url)[search_param]
    end

  end
end