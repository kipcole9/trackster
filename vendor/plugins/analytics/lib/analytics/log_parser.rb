module Analytics
  class LogParser
    LOG_ATTRIBUTES = {
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
  
    COMMON_LOG_FORMAT = [:ip_address, :remote, :user, :time, :request, :status, :size, :referer, :user_agent, :forwarded_for]
    LOG_DATE_FORMAT = '%d/%b/%Y:%H:%M:%S %z'
    
    attr_accessor :log_format_regexp, :log_format_string, :log_entry_attributes, :logger
  
    def initialize(options = {})
      @log_entry_attributes = (options.empty? || options[:format] == :common) ? COMMON_LOG_FORMAT : options[:format]
      validate_args!(@log_entry_attributes)
      @log_format_regexp = log_format_from(@log_entry_attributes)
      @logger = Trackster::Logger
      @logger.debug "[Log Parser] Log attributes are: #{@log_entry_attributes.join(', ')}"
      @logger.debug "[Log Parser] Log regexp is: #{@log_format_string}"
    end

    def parse(log_entry, &block)
      parsed_entry = parse_entry(log_entry)
      block_given? ? yield(parsed_entry) : parsed_entry
    end
    
  private
    # Parses the incoming log record and breaks it up into 
    # attribute hash
    def parse_entry(log_entry)
      attributes = log_entry_matches(log_entry).inject_with_index(Hash.new) do |attribs, match_item, index|
        attribs[log_entry_attributes[index]] = match_item
        attribs
      end
      attributes[:datetime] = log_datetime_from(attributes[:time])
      attributes[:method], 
      attributes[:request_uri], 
      attributes[:protocol] = attributes[:request].split(' ')
      attributes
    rescue NoMethodError => e
      logger.info "[Log Parser] Log record did not match the expected format (probably):"
      logger.info "[Log Parser] #{e}"
      logger.info "[Log Parser] #{log_entry}"
      nil
    end
    
    def validate_args!(log_format)
      raise ArgumentError, "[Log Parser] Log format should be an array. eg: :format => [:ip_addresss, :user, ....]" unless log_format.respond_to?(:each)
      log_format.each do |format| 
        raise ArgumentError, "[Log Parser] Unknown log attribute ':#{format}'." unless LOG_ATTRIBUTES[format]
      end
    end

    # Match data converted to an array.  Skip the first entry which is
    # the matched string
    def log_entry_matches(log_entry)
      log_entry.match(log_format_regexp).to_a[1..-1]
    end
    
    # Convert the log :time format into a real :datetime
    def log_datetime_from(log_time)
      DateTime.strptime(log_time, LOG_DATE_FORMAT) rescue nil
    end
    
    # Translate the defined log attributes into string representations of the 
    # appropriate regexp matcher.  Combine them and return as a regexp.
    def log_format_from(log_entry_attributes)
      attribute_formats = log_entry_attributes.inject([]) do |format, attribute|
        format << LOG_ATTRIBUTES[attribute]
      end
      @log_format_string = "\\A" + attribute_formats.join(' ') + "\\Z"
      Regexp.new(@log_format_string)
    end
  end
end