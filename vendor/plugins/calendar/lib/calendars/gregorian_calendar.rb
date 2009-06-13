class GregorianCalendar < Calendar
  DEFAULT_OPTIONS = {:year_starts_in              => :january,          # Starting month
                     :week_starts_on              => :sunday,           # For week calculations
                     :year                        => -1,                # Which fiscal year? -1 means current year
                     :fiscal_year_is_ending_year  => true,             # Fiscal year starts in this year (and ends in the next)
                     :calendar_range              => :year,             # Default range for the calendar object
                     :week_starts_with_first_day  => true,              # Weeks are calculate starting from the week that includes the first days of the year/quarter/month
                     :work_days => WORK_DAYS, :weekend => WEEKEND}
  
  def first_day_of_year(year = @options[:year])
    @first_day_of_year[year] ||= Date.new(fiscal_year_starts_in_calendar_year(year), year_starts_in_month_number, 1)
  end

  def last_day_of_year(year = @options[:year])
    @last_day_of_year[year] ||= Date.new(fiscal_year_starts_in_calendar_year(year) + 1, year_starts_in_month_number, 1) - 1
  end
  
  # Note that a year is bounded by the first day of the first quarter and the
  # last day of the last quarter.
  def first_day_of_quarter(quarter)
    @first_day_of_quarter[fiscal_year] ||= {}
    @first_day_of_quarter[fiscal_year][quarter] ||= Date.new(quarter_start_year(quarter), quarter_start_month(quarter), 1)
  end
  
  def last_day_of_quarter(quarter)
    @last_day_of_quarter[fiscal_year] ||= {}
    @last_day_of_quarter[fiscal_year][quarter] ||= Date.new(quarter_end_year(quarter), quarter_end_month(quarter), -1)
  end
  
  # Months are defined here.  The argument is the ordinal number of the
  # fiscal year (ie. 1..12 although these map to the fiscal year, no the
  # gregorian year)
  def first_day_of_month(month)
    #puts "first_day_of_month #{month}"
    #puts "Year #{calendar_year_of_nth_month(month)}"
    #puts "Month #{nth_month_of_year(month)}"
    Date.new(calendar_year_of_nth_month(month), nth_month_of_year(month), 1)
  end
  
  def last_day_of_month(month)
    (first_day_of_month(month) >> 1) -1
  end

  # Following three methods are used by the
  # calendar_to_fiscal method in the base Calendar class
  def quarter_of_year(date = Time.now.to_date)
    quarter_of_nth_month(calendar_to_fiscal_month(date.month))
  end
  
  def month_of_year(date = Time.now.to_date)
    calendar_to_fiscal_month(date.month)
  end
  
  def week_of_year(date = Time.now.to_date)
    start_of_this_week = start_of_week(date)
    first_week_of_this_year = start_of_week(first_day_of_year)
    (start_of_this_week - first_week_of_this_year).to_i / 7 + 1
  end
  
  def month_of_quarter(date = Time.now.to_date)
    quarter_of_nth_month(month_of_year(date))
  end
  
  # The nth 'x' day.  From the beginning of the period
  # if its positive.  From the end of the period if not.
  def nth_x_day(nth, day)
    nth = Date::KEYS[nth] if nth.is_a?(Symbol)
    start = nth > 0 ? self.first.nth_x_day(:first, day) : self.last.nth_x_day(:last, day)
    date = start + ((nth > 0 ? nth - 1 : nth + 1) * 7)
    raise ArgumentError, "Invalid Date" if date > self.last || date < self.first
    date
  end

#private
  # What is the calendar year of this fiscal month
  def calendar_year_of_nth_month(month)
    nth_month_of_year(month) < year_starts_in_month_number ? fiscal_year_ends_in_calendar_year : fiscal_year_starts_in_calendar_year
  end
  
  # What quarter of the fiscal year is this
  # fiscal month in
  def quarter_of_nth_month(month)
    case month
    when 1..3   then return 1
    when 4..6   then return 2
    when 7..9   then return 3
    when 10..12 then return 4
    end
    raise ArgumentError, "Invalid month #{month} is nth #{nth_month_of_year(month)}."
  end

  # IF the first month is > start_month_of_the_year and less < 12 then its the starting year.
  # else its the ending year
  def quarter_start_year(quarter)
    if quarter_start_month(quarter) >= year_starts_in_month_number && quarter_start_month(quarter) <= MONTHS_IN_YEAR
      fiscal_year_starts_in_calendar_year
    else
      fiscal_year_ends_in_calendar_year
    end
  end
  
  def quarter_end_year(quarter)
    quarter_end_month(quarter) > quarter_start_month(quarter) ? quarter_start_year(quarter) : quarter_start_year(quarter) + 1
  end
  
  def quarter_start_month(quarter)
    month = (year_starts_in_month_number + (quarter - 1) * MONTHS_IN_QUARTER) % MONTHS_IN_YEAR
    month == 0 ? MONTHS_IN_YEAR : month    
  end  
  
  def quarter_end_month(quarter)
    month = (quarter_start_month(quarter) + 2) % MONTHS_IN_YEAR
    month == 0 ? MONTHS_IN_YEAR : month
  end
  
  def week_starts_with_first_day?
    @options[:week_starts_with_first_day]
  end
    
  def fiscal_year_ends_in_month
    nth_month_of_year(MONTHS_IN_YEAR)
  end
  
  # What is the nth month of the fiscal year
  # If year starts in September then the nth_month(1) = 9
  def nth_month_of_year(m)
    nth = (year_starts_in_month_number + m - 1) % MONTHS_IN_YEAR
    nth == 0 ? 12 : nth
  end
    
  # Opposite of above.  Given a calendar month number, return
  # the fiscal month number.
  # If the year starts in September then calendar_to_fiscal_month(1) == 5
  # because January is the 5th month of a year that starts in September.  
  def calendar_to_fiscal_month(m)  
    if m < year_starts_in_month_number
      nth = MONTHS_IN_YEAR - year_starts_in_month_number + m + 1
    else
      nth = m - year_starts_in_month_number + 1
    end
    nth == 0 ? 1 : nth
  end

  def truncate_week(end_of_week, cutoff_date)
    end_of_week > cutoff_date ? cutoff_date : end_of_week
  end
  
  def truncated_week?(start_date, end_date)
    (end_date - start_date) < 6
  end
  
  def additional_calendar_weeks
    return 0 unless calendar_range == :month
    week(weeks).last >= Date.new(range.last.year, range.last.month, -1) ? 0 : 1
  end
  
end