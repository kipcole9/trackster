class Date
  DAYS_IN_WEEK      = 7
  MONTHS_IN_YEAR    = 12
  DAYS              = {:sunday => 0, :monday => 1, :tuesday => 2, :wednesday => 3, :thursday => 4, :friday => 5, :saturday => 6}
  MONTHS            = {:january => 1, :february => 2, :march => 3, :april => 4, :may => 5, :june => 6,
                       :july => 7, :august => 8, :september => 9, :october => 10, :november => 11, :december => 12}
  KEYS              = {:first => 1, :second => 2, :third => 3, :fourth => 4, :fifth => 5,
                       :"1st" => 1, :"2nd" => 2, :"3rd" => 3, :"4th" => 4, :"5th" => 5,
                      :last => -1}
  @@calendar        = nil                    
                      
  # Calculate the 'n'th or last day (Mon..Sun) in a given month
  def nth_x_day(nth, day)
    nth = KEYS[nth] if nth.is_a?(Symbol)
    if nth.is_a?(Integer) && nth > 0
      day = (DAYS_IN_WEEK - self.first_day_of_month.wday + DAYS[day]) % 7 + 1 + (nth - 1) * DAYS_IN_WEEK
    elsif nth == -1
      day = self.days_in_month - (self.last_day_of_month.wday - DAYS[day] + 7) % 7
    else
      raise ArgumentError, "Invalid date"
    end
    Date.new(self.year, self.month, day)
  end

  def days_in_month
    last_day = Date.new(self.year, self.month, -1)
    first_day = Date.new(self.year, self.month, 1)
    (last_day - first_day + 1).to_i
  end

  def last_day_of_month
    Date.new(self.year, self.month, self.days_in_month)
  end

  def first_day_of_month
    Date.new(self.year, self.month, 1)
  end
  
  def self.day_of_week(day)
    DAYS.index(day.wday)
  end
  
  def self.day_after(day)
    i = DAYS[day]
    i == 6 ? DAYS.index(0) : DAYS.index(i + 1)
  end
  
  def self.day_before(day)
    i = DAYS[day]
    i == 0 ? DAYS.index(6) : DAYS.index(i - 1)
  end
  
  def easter(method = :gregorian)
    # Based upon: http://www.tondering.dk/claus/cal/node3.html#SECTION003131000000000000000
    # g = is the Golden Number-1
    # h = 23-Epact (modulo 30)
    # i = the number of days from 21 March to the Paschal full moon
    # j = the weekday for the Paschal full moon (0=Sunday, 1=Monday, etc.)
    # l = the number of days from 21 March to the Sunday on or before the Paschal full moon (a number between -6 and 28)
    raise ArgumentError, "easter must be either :gregorian or :julian" unless [:gregorian, :julian].include?(method)
    year = self.year
    g = year % 19
    if method == :julian
      i = (19 * g + 15) % 30
      j = (year + year / 4 + i) % 7
    else
      c = year/100
      h = (c - c / 4 - (8 * c + 13) / 25 + 19 * g + 15) % 30
      i = h - h / 28 * (1 - 29 / (h + 1) * (21 - g) / 11)
      j = (year + year / 4 + i + 2 - c + c / 4) % 7
    end
    l = i - j
    easter_month = 3 + (l + 40) / 44
    easter_day = l + 28 - 31 * (easter_month / 4)
    method == :gregorian ? Date.civil(year, easter_month, easter_day) : Date.julian_to_civil(year, easter_month, easter_day)
  end
  
  # Considers year, month, day on the Julian calendar
  # and returns the Gregorian equivalent
  def self.julian_to_civil(year, month, day)
    e = 365.25 * (year + 4716)
    f = 30.6001 * (month + 1)
    d = day + e + f - 1524.5
    jd = Date.ajd_to_jd(d)
    civil = Date.jd_to_civil(jd[0])
    Date.civil(civil[0], civil[1], civil[2])
  end

  def self.nth_x_day(nth, day, date = Date.today)
    date.nth_x_day(nth, day)
  end
  
  def self.easter(date = Date.today, method = :gregorian)
    date = Date.new(date, 1, 1) if date.is_a?(Integer)
    date.easter(method)
  end
 
  def self.method_missing(method, *args)
    # first_monday_in_june or last_wednesday_in_september_2009 formats
    pattern = method.to_s.downcase
    expression = "\\A(#{valid_keys(KEYS)})_(#{valid_keys(DAYS)})_in_(#{valid_keys(MONTHS)})(_(\\d{4}))?\\Z"
    result = pattern.match(expression)
    if result
      year = result[5] ? result[5].to_i : Date.today.year
      date = Date.new(year, MONTHS[result[3].to_sym], 1)
      Date.nth_x_day(result[1].to_sym, result[2].to_sym, date)
    else
      super
    end
  end

  def self.days_regexp
    self.valid_keys(DAYS)
  end
  
  def self.months_regexp
    self.valid_keys(MONTHS)
  end
  
  def self.calendar=(calendar)
    @@calendar = calendar
  end
  
  def fiscal_day
    raise InvalidDate, "Invalid calendar" unless valid_calendar?
    @@calendar.includes(self).day_of_year(self)
  end
  
  def fiscal_week
    raise InvalidDate, "Invalid calendar" unless valid_calendar?
    @@calendar.includes(self).week_of_year(self)
  end
  
  def fiscal_month
    raise InvalidDate, "Invalid calendar" unless valid_calendar?
    @@calendar.includes(self).month_of_year(self)
  end
  
  def fiscal_quarter
    raise InvalidDate, "Invalid calendar" unless valid_calendar?
    @@calendar.includes(self).quarter_of_year(self)
  end
  
  def fiscal_week_of_quarter
    raise InvalidDate, "Invalid calendar" unless valid_calendar?
    @@calendar.includes(self).week_of_quarter(self)
  end
  
  def fiscal_year
    raise InvalidDate, "Invalid calendar" unless valid_calendar?
    @@calendar.includes(self).fiscal_year
  end
    
private
  def self.valid_keys(collection)
    collection.collect{|a| a[0].to_s}.join('|')
  end
  
  def valid_calendar?
    @@calendar && @@calendar.respond_to?(:day_of_year)
  end
  
end