module Options

  def fiscal_year
    @options[:year]
  end

  def is_work_day?(date)
    @options[:work_days].include?(Date.day_of_week(date))
  end

  def is_weekend?(date)
    @options[:weekend].include?(Date.day_of_week(date))
  end

  def weeks_are_month_aligned?
    @options[:week_starts_on] == :aligned
  end

  def year_starts_in
    @options[:year_starts_in]
  end

  def year_starts_in_month_number
    Date::MONTHS[@options[:year_starts_in]]
  end

  def first_or_last
    @options[:first_or_last]
  end

  def begins_on
    @options[:ends_or_begins] == :begins
  end

  def ends_on
    @options[:ends_or_begins] == :ends
  end

  def calendar_range
    @options[:calendar_range]
  end

  def requested_year
    @options[:year]
  end

  def requested_quarter
    @options[:quarter]
  end

  def requested_month
    @options[:month]
  end

  def requested_week
    @options[:week]
  end

  def week_starts_on
    @options[:week_starts_on] || @options[:year_starts_on]
  end

  def week_ends_on
    Date.day_before(week_starts_on)
  end

  def week_starts_on_day_number
    Date::DAYS[week_starts_on]
  end

  def fiscal_year_is_ending_year?
    @options[:fiscal_year_is_ending_year]
  end

end
