# /private/var/log/apache2
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
  
  NGINX_LOG = [:ip_address, :remote, :user, :time, :request, :status, :size, :referer, :user_agent, :forwarded_for]
  DATE_FORMAT = '%d/%b/%Y:%H:%M:%S %z'
  attr_accessor   :format, :regexp, :column
  
  def initialize(*args)
    if args.empty? || args.last == :nginx
      @args = NGINX_LOG
    else
      @args = args
    end
    
    validate_args!(@args)
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
    row = web_analyser.create(entry)
    Session.transaction do
      if session = Session.find_or_create_from_track(row)
        session.save! if session.new_record?
        if event = Event.create_from_row(session, row)
          event.save! 
          session.update_viewcount!
        else
          Rails.logger.error "Event could not be created"
          Rails.logger.error row.inspect
        end
      else
        Rails.logger.error "Sesssion was not found or created!  Unknown web property?"
        Rails.logger.error row.inspect
      end
    end
  rescue Mysql::Error => e
    Rails.logger.warn "Database could not save this data: #{e.message}"
    Rails.logger.warn row.inspect
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Invalid record detected: #{e.message}"
    Rails.logger.error row.inspect
  end    

private
  def validate_args!(args)
    args.each {|arg| raise(ArgumentError, "Unknown log attribute ':#{arg}'.") unless ATTRIBS[arg]}
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

end