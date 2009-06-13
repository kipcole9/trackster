# This class acts as a proxy between an ActiveRecord composed_of
# calendar and the calendar class. 
# In this class we just handle the parameter marshalling and instantiating
# a Calendar subclass.  Everything else we pass through to that class.
class CalendarProxy
  
   # Order sensitive.  Its how we define the mapping for the composed_of
   PARAMETERS            = [:calendar_type,               # Only for our proxy to work out what to instantiate
                          :calendar_month,              # Both calendars
                          :calendar_begins_or_ends,     # 13-week only
                          :calendar_first_or_last,      # 13-week only
                          :calendar_day_of_week,        # Both calendars, but different names
                          :calendar_first_or_full,      # Gregorian only
                          :calendar_use_ending_year,    # Gregorian ony
                          :calendar_quarter_type        # 13-week only
                         ]
  COMPOSED_OF_MAPPING   = PARAMETERS.collect{|p| [p, p]}                       
                         
  GREGORIAN_MAPPING     = {
                            :year_starts_in              => :calendar_month,
                            :week_starts_on              => :calendar_day_of_week,
                            :fiscal_year_is_ending_year  => :calendar_use_ending_year,
                            :week_starts_with_first_day  => :calendar_first_or_full
                          }
                          
  THIRTEEN_WEEK_MAPPING = {
                            :ends_or_begins              => :calendar_begins_or_ends,
                            :first_or_last               => :calendar_first_or_last,
                            :week_starts_on              => :calendar_day_of_week,
                            :year_starts_in              => :calendar_month,
                            :fiscal_year_is_ending_year  => :calendar_use_ending_year,
                            :type                        => :calendar_quarter_type                            
                          }                        


  PARAMETERS.each {|a| attr_writer a}                   
  attr_accessor           :calendar, :options

  def initialize(*args)
    if args.first.is_a?(Calendar)
      @calendar = args.first
    else
      @calendar_type = args.first
      @calendar = Calendar.send calendar_type, options_from_args(args).merge(:year => Time.now.year)
    end
  end
  
  def logger
    RAILS_DEFAULT_LOGGER
  end
  
  def inspect
    @calendar.inspect
  end
  
  def options_from_args(args)
    args.last.is_a?(Hash) ? options_from_hash(args.last) : options_from_params(args)
    calendar_options_from_hash
  end
  
  def options_from_hash(options)
    options.each {|k, v| send "#{k.to_s}=", v}
  end
    
  def options_from_params(params)
    # Set the instance variables (via their setters)
    params.each_with_index do |param, index|
      send "#{PARAMETERS[index].to_s}=", params[index]
    end
  end
    
  def calendar_options_from_hash
    # Convert them to options
    @options = {}
    param_map = calendar_type == "gregorian" ? GREGORIAN_MAPPING : THIRTEEN_WEEK_MAPPING
    param_map.each do |k, v|
      value = send(v.to_s)
      puts "#{v}: #{value}"
      unless value.nil?
        value.is_a?(String) ? @options[k] = value.to_sym : @options[k] = value
      end
    end
    adjust_start_of_week
    adjust_first_or_full
    @options
  end
  
  def calendar_type
    @calendar_type || (@calendar.class == GregorianCalendar ? "gregorian" : "thirteen_week")
  end
  
  def adjust_start_of_week
    if @options[:ends_or_begins] == :ends
      @options[:week_starts_on] = Date.day_after(@options[:week_starts_on])
    end
  end
  
  def adjust_return_method(method, result)
    if method == :week_starts_with_first_day
      case result
        when 'true', true then return "first"
        when 'false', false then return "full"
        else return result
      end
    elsif method == :week_starts_on && @options[:ends_or_begins] == :ends
      logger.warn "======================="
      logger.warn "Adjusting week_starts_on because of 'ends'"
      logger.warn "Pre-transform result is #{result.inspect}"
      logger.warn "======================="
      # need to back pedal the start day because it's been adjusted
      # in the calendar object
      # return Date.day_before(result.to_sym).to_s
      result
    else
      result
    end
  end
  
  def adjust_first_or_full
    @options[:week_starts_with_first_day] = calendar_first_or_full == "first"
  end
      
  def method_missing(method, *args)
    if method.to_s =~ /\Acalendar_.+/
      map_method = GREGORIAN_MAPPING.index(method) || THIRTEEN_WEEK_MAPPING.index(method)
      result = @calendar ? @calendar.send("options")[map_method].to_s : instance_variable_get("@#{method.to_s}") 
      result = result.blank? ? nil : result
      adjust_return_method(map_method, result)
    else  
      @calendar.send method, *args
    end
  end
  
end