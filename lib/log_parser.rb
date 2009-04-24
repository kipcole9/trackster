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
  SEARCH_BOTS = /(Googlebot|yahoo! slurp|msnbot|Twiceler|DotBot|friendfeed|MJ12bot|NetNewsWire|CCBot|Technoratibot|Shere Scout|Moreoverbot|BlogPulseLive)/i
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
  
  def parse_entry(log_entry)
    @column = {}; i = 1;
    if attributes = log_entry.match(regexp)
      @args.each {|f| @column[f] = attributes[i]; i += 1}
      parse_datetime! if @column[:time]
      parse_request! if @column[:request]
    end
    @column
  end
  
  def parse_log(filename)
    web_analyser = WebAnalytics.new
    last_log_time = Date.new(2009, 4, 5)
    RAILS_DEFAULT_LOGGER.debug "Last start time is #{last_log_time}. No entries before that time will be imported."
    File.open(filename, "r") do |infile|
      while (line = infile.gets)
        entry = parse_entry(line)
        if entry[:datetime] && entry[:datetime] > last_log_time
          if block_given?
            yield entry
          else
            save_web_analytics!(web_analyser, entry) unless is_search_bot?(entry[:user_agent])
          end
        end
      end
    end
  end
  
  def save_web_analytics!(web_analyser, entry)
    row = web_analyser.create(entry[:url])
    row.referrer = entry[:referer]
    row.ip_address = entry[:ip_address]
    row.tracked_at = entry[:datetime]
    row.user_agent = entry[:user_agent]
    geocode_location(row)
    unless row.save
      RAILS_DEFAULT_LOGGER.warn "Could not save this data."
      RAILS_DEFAULT_LOGGER.warn row.errors.inspect
    end
  rescue Mysql::Error => e
    RAILS_DEFAULT_LOGGER.warn "Could not save this data."
    RAILS_DEFAULT_LOGGER.warn e.message   
  end    
  
  def geocode_log(model = Track)
    model.find_each(:conditions => "geocoded_at IS NULL and ip_address IS NOT NULL") do |row|
      geocode_location(row)
      row.save!
    end
  end
  
  def geocode_location(row)
    begin  
      location = Graticule.service(:host_ip).new.locate(row.ip_address)
      row.country = location.country
      row.region = location.region
      row.locality = location.locality
      row.latitude = location.latitude
      row.longitude = location.longitude
      row.geocoded_at = Time.now()
    rescue Graticule::Error => e
      RAILS_DEFAULT_LOGGER.warn "An error occurred while looking up the location of '#{row.ip_address}': #{e.message}"
      nil
    end
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
  
  def is_search_bot?(user_agent)
    user_agent && user_agent =~ SEARCH_BOTS
  end
end