class Calendar 
  include Enumerable
  include Calendar::Options
  include Calendar::Operators
  include Calendar::Metrics
  include Calendar::HtmlOutput
  
  DAYS_IN_WEEK      = 7
  MONTHS_IN_YEAR    = 12
  MONTHS_IN_QUARTER = 3
  QUARTERS_IN_YEAR  = 4
  WEEKS_IN_YEAR     = 53  # max number of weeks
  SHORT_DATE_FORMAT = "%a, %b %d %Y"
  WORK_DAYS         = [:monday, :tuesday, :wednesday, :thursday, :friday]
  WEEKEND           = [:saturday, :sunday]
  DEFAULT_CALENDAR  = :GregorianCalendar                     

  attr_reader       :range, :options
  
  def initialize(options = {})
    if self.class == Calendar
      raise RuntimeError, "Don't instantiate Calendar base class"
    else
      initialize_cache_variables
      @options = self.class::DEFAULT_OPTIONS.merge(options)
      parse_options(@options)
      @range = calendar_range_from_options(@options)
    end
    @logger = RAILS_DEFAULT_LOGGER
  end
  
  def is_a?(arg)
    arg == Range ? true : super
  end

  def logger
    @logger
  end

  def self.gregorian(options = {})
    GregorianCalendar.new(options)
  end

  def self.thirteen_week(options = {})
    ThirteenWeekCalendar.new(options)
  end

  def inspect
    first.strftime(SHORT_DATE_FORMAT) + ".." + last.strftime(SHORT_DATE_FORMAT) 
  end

  # Create a new calendar object for the specified year (default is current fiscal year)
  def year(y = self.includes(Time.now.to_date).fiscal_year)
    self.class.new(@options.merge(:year => y, :calendar_range => :year))
  end

  # Create a new calendar object for the specified quarter (default is current quarter)
  def quarter(q = quarter_of_year(Time.now.to_date))    
    raise ArgumentError, "Invalid quarter" if q < 0  || q > QUARTERS_IN_YEAR
    self.class.new(@options.merge(:quarter => q, :calendar_range => :quarter))
  end

  # Create a new calendar object for the specified month (default is current month)  
  def month(m = month_of_year(Time.now.to_date))
    raise ArgumentError, "Invalid month" if m < 0  || m > MONTHS_IN_YEAR
    self.class.new(@options.merge(:month => m, :calendar_range => :month))
  end

  # Create a new calendar object for the specified week (default is current week)    
  def week(w = week_of_year(Time.now.to_date))
    raise ArgumentError, "Invalid week" if w < 0 || w > WEEKS_IN_YEAR
    self.class.new(@options.merge(:week => w, :calendar_range => :week))
  end

  # Return the nth day of the current calendar
  # positive numbers from the starts of the calendar range
  # negative numbers from the end of the calendar range
  def day(d)
    calculated_day = (d > 0) ? range.first + d - 1 : range.last + d + 1
    raise ArgumentError, "Invalid day" if calculated_day > range.last || calculated_day < range.first
    calculated_day
  end

  # Return a calendar that includes the given date
  def includes(date)
    best_guess = self.class.new(@options.merge(:year => date.year, :calendar_range => :year))
    return best_guess if best_guess.range.include?(date)
    if date > best_guess.last
      self.class.new(@options.merge(:year => date.year + 1, :calendar_range => :year))
    else
      self.class.new(@options.merge(:year => date.year - 1, :calendar_range => :year))
    end
  end

  def by_week
    (1..weeks).each do |week_number|
      this_week = w(week_number)
      yield(week_number, this_week.first, this_week.last)
    end
    self
  end

  def by_month
    (1..months).each do |month_number|
      this_month = m(month_number)
      yield(month_number, this_month.first, this_month.last)
    end
    self
  end

protected
  # Calculate the fiscal year
  def y(year)
    @years[year] ||= first_day_of_year(year)..last_day_of_year(year)
  end

  # Calculate a fiscal month
  def m(mo)
    requested_quarter ? month_within_quarter(mo) : month_within_year(mo)
  end

  # Calculate a fiscal quarter
  def q(quarter) 
    @quarters[quarter] ||= first_day_of_quarter(quarter)..last_day_of_quarter(quarter)
  end

  # Week calculations can be in the context of either a year, quarter or month.
  def w(week)
    if requested_month
      week_in_period(week, m(requested_month))
    elsif requested_quarter
      week_in_period(week, q(requested_quarter))
    else
      week_in_period(week, y(fiscal_year))
    end
  end

  # Weeks start on either the specified starting day of a week (options[:week_starts_on => :monday] for example.)
  # Or they start aligned from the beginning of the month (quarter, or year).
  # In most cases, the beginning of the period will not coincide with the beginning of a week.  So we have to make a choice.
  # Does the week start before the period, or after.  This is controlled by options[:week_starts_with_first_day].
  # For the end case, weeks are always 7 days long, with one exception.  If the weeks are aligned to month boundaries
  # then the last week of a period may be truncated.
  def week_in_period(week, period = range)
    beginning_of_week = start_of_week(period.first) + ((week - 1) * DAYS_IN_WEEK)
    beginning_of_week += DAYS_IN_WEEK if beginning_of_week < period.first && !week_starts_with_first_day?
    end_of_week = beginning_of_week + DAYS_IN_WEEK - 1
    end_of_week = truncate_week(end_of_week, period.last) if weeks_are_month_aligned?
    if (beginning_of_week > period.last) # || (end_of_week > period.last && week_starts_with_first_day?)
      raise ArgumentError, "Invalid week #{week} specified for the period #{period}."
    end
    beginning_of_week..end_of_week
  end

  # Get the nth week from the start of the period
  # and dont' raise any errors.  Used for html calendars
  def week_without_bounds(week_number)
    week_one = week_in_period(1)
    start_of_week = week_one.first + ((week_number - 1) * DAYS_IN_WEEK)
    end_of_week = start_of_week + 6
    start_of_week..end_of_week
  end

  # Returns the date that is the beginning of the week
  # in which the start_of_period date occurs
  # Called only with a date that is already the start of a fiscal period
  def start_of_week(start_of_period)
    if weeks_are_month_aligned?
      start_of_period
    else
      start_date = start_of_period - (start_of_period.wday - Date::DAYS[week_starts_on])
      start_date -= DAYS_IN_WEEK if start_date > start_of_period && week_starts_with_first_day?
      start_date
    end
  end

  # Calendar creation methods invoked at object
  # creation (after options are parsed)
  def calendar_range_from_options(options)
    send "#{options[:calendar_range]}_range_from_options", options
  end  

  def year_range_from_options(options)
    year_range = y(options[:year])
    if year_range.last.year == -1
      year = self.includes(Time.now.to_date)
      options[:year] = year.fiscal_year
      year_range = year.range
    end
    year_range
  end

  def quarter_range_from_options(options)
    q(options[:quarter])
  end

  def month_range_from_options(options)
    m(options[:month])
  end

  def week_range_from_options(options)
    w(options[:week])
  end

  # Defines the calendar year for the start and end of the fiscal year
  # Any :years_starts_in other than :january 1st means that the two will
  # be different as the year will straddle the calendar year
  def fiscal_year_starts_in_calendar_year(year =  @options[:year])
    fiscal_year_is_ending_year? && year_starts_in_month_number > 1 ? year - 1 : year
  end

  # Unless the year starts in January, the end of the year is in the calendar
  # year later
  def fiscal_year_ends_in_calendar_year(year = @options[:year])
    return year if fiscal_year_is_ending_year?
    year_starts_in_month_number == 1 ? fiscal_year_starts_in_calendar_year(year) : fiscal_year_starts_in_calendar_year(year) + 1
  end
  
private
  def parse_options(options)
    # begins_first_wednesday_of_january_2009 and variations
    # wednesday (ie. day of week) is the minimum required to match
    # nearest is an option not yet implemented
    reg = "\\A((begins|ends)_)?((nearest)_)?((first|last)_)?(#{Date.days_regexp})(_(of|in)_(#{Date.months_regexp}))?(_(\\d{4}))?\\Z"
    if options[:defined_by] && (year_parts = options[:defined_by].to_s.match(reg))
      options[:week_starts_on] = year_parts[7].to_sym
      options[:year_starts_in] = year_parts[10].to_sym if year_parts[10]
      options[:ends_or_begins] = year_parts[2].to_sym if year_parts[2]
      options[:nearest]        = year_parts[4].to_sym if year_parts[4]
      options[:first_or_last]  = year_parts[6].to_sym if year_parts[6]
      options[:year]           = year_parts[12].to_i   if year_parts[12]
      options[:week_starts_on] = Date.day_after(options[:week_starts_on]) if ends_on
    elsif ends_on && options[:week_ends_on]
      options[:week_starts_on] =  Date.day_after(options[:week_ends_on])
      options.delete(:week_ends_on)
    else
      raise ArgumentError, "Invalid date" unless options[:defined_by].nil?
    end
    raise ArgumentError, "Invalid weekday '#{options[:week_starts_on]}'" if options[:week_starts_on] && !Date::DAYS[options[:week_starts_on]]
    raise ArgumentError, "Invalid start month '#{options[:year_starts_in]}'" if options[:year_starts_in] && !Date::MONTHS[options[:year_starts_in]]
    before_calendar
  end

  def before_calendar
    # abstract method - implement in subclass
    # to do stuff at the end of initialize()
  end
  
  def initialize_cache_variables
    @first_day_of_year = {}
    @last_day_of_year = {}
    @first_day_of_quarter = {}
    @last_day_of_quarter = {}
    @years = {}
    @quarters = {}
  end

  def method_missing(method, *args)
    if method.to_s.match(/\Ayear(_)?(\d{4})\Z/i)
      year($2.to_i)
    elsif method.to_s.match(/\Aquarter(_)?([1234])\Z/i)
      quarter($2.to_i)
    elsif method.to_s.match(/\Aweek(_)?(\d{1,2})\Z/i)
      week($2.to_i)   
    elsif method.to_s.match(/\Amonth(_)?(\d{1,2})\Z/i)
      month($2.to_i)
    else
      # first_sunday, last_monday, for example
      pattern = method.to_s.downcase
      result = pattern.match(/\A([[:alnum:]]+)_([[:alpha:]]+)\Z/)
      if result && Date::DAYS[result[2].to_sym]
        self.nth_x_day(result[1].to_sym, result[2].to_sym)
      else
        super
      end
    end  
  end

  # Return a new calendar incremented/decremented
  # by the specified amount
  def increment_range(increment)
    if calendar_range == :year then
      year(fiscal_year + increment)
    elsif calendar_range == :quarter
      quarter(quarter_of_year + increment)
    elsif calendar_range == :month
      month(month_of_year + increment)
    elsif calendar_range == :week
      week(week_of_year + increment)
    else
      raise RuntimeError, "Invalid calendar range detected in calendar#+"
    end
  end

  # Create a new default calendar and try to send it the
  # message
  def self.method_missing(method, *args)
    calendar = const_get(DEFAULT_CALENDAR).new(:year => Time.now.year)
    calendar.send method, *args
  end

  # How many extra weeks (above the official fiscal weeks) should
  # we display in a calendar.  Implement in sub-class
  def additional_calendar_weeks
    0
  end

end

