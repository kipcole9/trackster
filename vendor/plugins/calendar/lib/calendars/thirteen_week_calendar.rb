class ThirteenWeekCalendar < Calendar  
  DEFAULT_OPTIONS   = {:ends_or_begins  => :begins,         # Begins, ends   
                       :first_or_last   => :first,          # First, last or nearest :year_starts_on
                       :nearest         => nil,             # If nearest (as apposed to exactly on)
                       :week_starts_on  => :sunday,         # Day of week
                       :year_starts_in  => :january,        # Starting month
                       :year            => -1,              # Calendar for which year? 0 means "this year"
                       :calendar_range  => :year,           # Default calendar range
                       :fiscal_year_is_ending_year => true, # eg. FY2009 ends in 2009 (not necessarily starts in 2009)                   
                       :type            => "445",           # Quarters are in 3 months of lengths 4, 4 and 5 weeks respectively
                       :work_days => WORK_DAYS, :weekend => WEEKEND}
  WEEKS_IN_QUARTER  = 13 
  VALID_QUARTERS    = ["445", "454", "544"]                

  def first_day_of_year(year = @options[:year])
    if begins_on
      @first_day_of_year[year] ||= start_date = Date.new(fiscal_year_starts_in_calendar_year(year), year_starts_in_month_number, 1).nth_x_day(first_or_last, week_starts_on)
    else
      last_day_of_year(year - 1) + 1
    end
  end
  
  def last_day_of_year(year = @options[:year])
    if begins_on
      first_day_of_year(year + 1) - 1
    else
      @last_day_of_year[year] ||= Date.new(fiscal_year_ends_in_calendar_year(year), year_starts_in_month_number, 1).nth_x_day(first_or_last, week_ends_on)
    end
  end

  def first_day_of_quarter(quarter)
    @first_day_of_quarter[fiscal_year] ||= {}
    @first_day_of_quarter[fiscal_year][quarter] ||= first_day_of_year + (quarter - 1) * (WEEKS_IN_QUARTER * DAYS_IN_WEEK)
  end
  
  def last_day_of_quarter(quarter)
    last_day = first_day_of_quarter(quarter) + (WEEKS_IN_QUARTER * DAYS_IN_WEEK) - 1
    last_day += DAYS_IN_WEEK if add_additional_week_in_last_quarter? && quarter == QUARTERS_IN_YEAR
    last_day
  end
  
  # Months are defined here.  The argument is the ordinal number of the
  # fiscal year (ie. 1..12 although these map to the fiscal year, not the
  # gregorian year)
  def first_day_of_month(month)
    first_day_of_year + @length_of_months[1..month - 1].sum * DAYS_IN_WEEK
  end
  
  def last_day_of_month(month)
    first_day_of_month(month) + @length_of_months[month] * DAYS_IN_WEEK - 1
  end

  def quarter_of_year(date = Time.now.to_date)
    case month_of_year(date)
    when 1..3   then return 1
    when 4..6   then return 2
    when 7..9   then return 3
    when 10..12 then return 4
    end
  end
  
  def month_of_year(date = Time.now.to_date)
    # TODO: This is Ugly iteration.
    (1..MONTHS_IN_YEAR).each do |month|
      return month if date >= m(month).first && date <= m(month).last
    end
    raise ArgumentError, "Date is not in this year"
  end
  
  def month_of_quarter(date = Time.now.to_date)
    case month_of_year(date)
      when 1, 4, 7, 10 then return 1
      when 2, 5, 8, 11 then return 2
      when 3, 6, 9, 12 then return 3
    end
  end
  
  def week_of_year(date = Time.now.to_date)
    raise ArgumentError, "Date is not in this year" if date < first_day_of_year || date > last_day_of_year
    start_of_this_week = start_of_week(date)
    first_week_of_this_year = start_of_week(first_day_of_year)
    (start_of_this_week - first_week_of_this_year).to_i / DAYS_IN_WEEK + 1
  end
    
  def nth_x_day(nth, day)
    nth = Date::KEYS[nth] if nth.is_a?(Symbol)
    start = nth > 0 ? first_x_day(day) : last_x_day(day)
    date = start + ((nth > 0 ? nth - 1 : nth + 1) * DAYS_IN_WEEK)
    raise ArgumentError, "Invalid Date" if date > self.last || date < self.first
    date
  end
  
  def month_name
    raise ArgumentError, "month_name requires month calendar" unless calendar_range == :month
    logger.warn "==============="
    logger.warn "Month Name in Thirteen Week Calendar"
    logger.warn range.inspect
    most_common_month = range.inject(Hash.new(0)) {|h,x| h[x.month]+=1;h}
    logger.warn "Common month is #{most_common_month.inspect}"
    logger.warn "==============="
    Date::MONTHS.index(most_common_month.max{|a,b| a[1] <=> b[1]}[0])
  end
  

protected  
  def fiscal_year_starts_in_calendar_year(year = @options[:year])
    fiscal_year_is_ending_year?  ? year - 1 : year
  end
  
  def fiscal_year_end_in_calendar_year(year = @options[:year])
    year
  end
      
private
  def first_x_day(day)
    offset_to_requested_day = range.first.wday + Date::DAYS[day]
    first_day = range.first + offset_to_requested_day
    first_day -= DAYS_IN_WEEK if (first_day - DAYS_IN_WEEK) >= range.first
    first_day
  end

  def last_x_day(day)
    offset_to_requested_day = range.last.wday - Date::DAYS[day]
    last_day = range.last - offset_to_requested_day
    last_day += DAYS_IN_WEEK if (last_day + DAYS_IN_WEEK) <= range.last
    last_day
  end  

  def calculate_months(type)
    offset = [nil]
    (1..QUARTERS_IN_YEAR).each do
      (1..MONTHS_IN_QUARTER).each do |m|
        offset << @options[:type][m - 1, 1].to_i
      end
    end
    offset
  end

  def valid_quarter_type?
    @options[:type] = @options[:type].to_s
    raise ArgumentError, "Invalid quarter type '#{@options[:type]}'" unless VALID_QUARTERS.include?(@options[:type])
    true
  end
  
  def year_is_53_weeks?(year = @options[:year])
    @weeks_are_53 ||= (last_day_of_year(year) - first_day_of_year(year) + 1).to_i / DAYS_IN_WEEK == 53
  end

  def add_additional_week_in_last_quarter
    @length_of_months[-1] += 1
  end
  
  def add_additional_week_in_last_quarter?
    year_is_53_weeks?
  end
      
  def before_calendar
    @length_of_months = calculate_months(@options[:type]) if valid_quarter_type?
    add_additional_week_in_last_quarter if year_is_53_weeks?
  end
end


