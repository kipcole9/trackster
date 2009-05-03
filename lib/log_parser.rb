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
  include     CollectiveIdea::RemoteLocation
  
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
  
  # This method only scans a file to EOF and invokes the block on each parsed line
  # If you're reading live log files it will be no good because logs can be rotated.
  # In this case use log_tailer and friends.
  def parse_log(filename)
    web_analyser = WebAnalytics.new
    last_log_time = Track.try(:last).try(:tracked_at) || Time.now
    RAILS_DEFAULT_LOGGER.debug "Last start time is #{last_log_time}. No entries before that time will be imported."
    File.open(filename, "r") do |infile|
      while (line = infile.gets)
        entry = parse_entry(line)
        if entry[:datetime] && entry[:datetime] > last_log_time
          if block_given?
            yield entry
          else
            save_web_analytics!(web_analyser, entry) unless web_analyser.is_crawler?(entry[:user_agent])
          end
        end
      end
    end
  end
  
  # Main method for decoding a log file entry for its analytics content.
  # This method will create the Track, Session and Event objects and serialise
  # them to the database.  Feed a parsed row from a log file to this
  # method to save analytics data to the database. See log_tailer.rb for
  # the most relevant usage example or the method #parse_log above.
  # option[:geocode] if true will geocode the data.  You most likely want this to
  # be true since we are no resolving this data from the hostip.info database
  # locally (no net latency or performance issues).
  def save_web_analytics!(web_analyser, entry, options = {:geocode => true})
    row = web_analyser.create(entry)
    Track.transaction do
      row.save!
      session = Session.find_or_create_from_track(row)
      if session
        if session.new_record?
          geocode_location!(session) if options[:geocode]
          session.save!
        end
        if event = Event.create_from_row(session, row)
          event.save! 
          session.save!   # Updated viewcount
        end
      end
    end
  rescue Mysql::Error => e
    Rails.logger.warn "Could not save this data."
    Rails.logger.warn e.message
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Invalid record detected (validation error?)"
    Rails.logger.error e.message
  end    
  
  def geocode_log(model = Session)
    model.find_each(:conditions => "geocoded_at IS NULL and ip_address IS NOT NULL") do |row|
      geocode_location!(row)
      row.save!
    end
  end
  
  def geocode_location!(row) 
    IpAddress.reverse_geocode(row.ip_address, row)
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