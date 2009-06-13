module Metrics

  def calendar_to_fiscal(date = Time.now.to_date)
    calendar = self.includes(date)
    year            = calendar.fiscal_year    
    quarter         = calendar.quarter_of_year(date)
    month           = calendar.month_of_year(date)
    week            = calendar.week_of_year(date)
    week_of_quarter = calendar.week_of_quarter(date)
    day             = calendar.day_of_year(date)
    {:year => year, :quarter => quarter, :month => month, :week => week, :day => day, :week_of_quarter => week_of_quarter}
  end

  def quarter_of_year(date)
    raise "Implement quarter of year in subclass"
  end

  def month_of_year(date)
    raise "Implement month_of_year in subclass"
  end

  def week_of_year(date)
    raise "Implement week_of_year in subclass"
  end

  # Returns the fiscal day number within the fiscal year
  def day_of_year(date = Time.now.to_date)
    (date - first_day_of_year).to_i + 1
  end

  # Returns the fiscal week number within quarter
  def week_of_quarter(date = Time.now.to_date)
    start_of_quarter = start_of_week(q(quarter_of_year(date)).first)
    weeks(start_of_quarter, date)
  end

  # Returns the number of quarters between two dates
  def quarters(from = range.first, to = range.last)
    quarter_of_year(to) - quarter_of_year(from) + 1
  end

  # Returns the number of months between two dates
  def months(from = range.first, to = range.last)
    #puts "Month #{from} is #{month_of_year(from)}"
    #puts "Month #{to} is #{month_of_year(to)}"
    month_of_year(to) - month_of_year(from) + 1
  end

  # Returns the number of weeks between two dates
  def weeks(from = range.first, to = range.last)
    start_of_first_week = start_of_week(from)
    days(start_of_first_week, to) / Calendar::DAYS_IN_WEEK
  end

  # Returns the number of days between two dates
  def days(from = range.first, to = range.last)
    (to - from + 1).to_i
  end

  # Defines the month within the year.
  def month_within_year(month)
    first_day_of_month(month)..last_day_of_month(month)
  end

  # Defines the month within the quarter
  def month_within_quarter(month)
    raise ArgumentError, "Invalid month #{month} for quarter #{requested_quarter}" if month > Calendar::MONTHS_IN_QUARTER || month < 1
    requested_quarter_offset = (requested_quarter - 1) * Calendar:: MONTHS_IN_QUARTER + 1
    #puts "Quarter offset is #{requested_quarter_offset}"
    quarter_month = requested_quarter_offset + month - 1
    #puts "Month_with_quarter is #{quarter_month}"
    first_day_of_month(quarter_month)..last_day_of_month(quarter_month)
  end

  # Calculate the working days in the period
  def work_days(period = @range)
    period.dup.collect{|x| x if is_work_day?(x) }.compact!
  end
  alias workdays work_days

  # Calculate the weekend days in the period
  def weekend_days(period = @range)
    period.dup.collect{|x| x if is_weekend?(x) }.compact!
  end
  alias weekends weekend_days

  def days_of_week
    unless @days_of_week
      @days_of_week = []
      w(1).each do |d|
       @days_of_week << Date.day_of_week(d)
      end
    end
    @days_of_week
  end
 
  # Return the name of the month.
  # This lets us to calendar.month.month_name
  # or calendar.month(3).month_name (name of the third fiscal month)
  # Note that we're using the last day of the period to decide which month.
  #
  # Non gregorian calendars may need a different approach since their months
  # will span greogorian months.
  def month_name
    raise ArgumentError, "month_name requires month calendar" unless calendar_range == :month
    Date::MONTHS.index(range.last.month)
  end

    
    
    
    
    

end
