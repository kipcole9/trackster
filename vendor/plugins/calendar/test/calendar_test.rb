require 'test_helper'

class CalendarTest < ActiveSupport::TestCase
  DAYS = [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
  
  test "13 week calendars have continuous start and end years" do
    calendars = []
    (2000..2100).each do |y|
      calendars << Calendar.thirteen_week(:defined_by => :ends_last_saturday_in_july, :year => y)
    end
    (1..calendars.length - 1).each do |c|
      assert_equal(calendars[c].first, calendars[c-1].last + 1)
    end
  end
  
  test "Basic gregorian calendar has correct dates" do
    c = Calendar.gregorian
    assert_equal(Time.now.year, c.fiscal_year)
    assert_equal(c.range, Date.new(Time.now.year, 1, 1)..Date.new(Time.now.year, 12, 31))
  end
  
  test "gregorian calendars have continuous start and end years" do
    calendars = []
    (2000..2100).each do |y|
      calendars << Calendar.gregorian(:year_starts_in => :march, :year => y)
    end
    (1..calendars.length - 1).each do |c|
      assert_equal(calendars[c].first, calendars[c-1].last + 1)
    end
  end
  
  test "13 week calendar has 53 weeks in the appropriate years" do
    assert_equal(Calendar.thirteen_week(:defined_by => :ends_last_saturday_in_july, :year => 2004).weeks, 53)
    assert_equal(Calendar.thirteen_week(:defined_by => :ends_last_saturday_in_july, :year => 2010).weeks, 53)
    assert_equal(Calendar.thirteen_week(:defined_by => :ends_last_saturday_in_july, :year => 2016).weeks, 53)
    assert_equal(Calendar.thirteen_week(:defined_by => :ends_last_saturday_in_july, :year => 2021).weeks, 53)
    assert_equal(Calendar.thirteen_week(:defined_by => :ends_last_saturday_in_july, :year => 2027).weeks, 53)
    assert_equal(Calendar.thirteen_week(:defined_by => :ends_last_saturday_in_july, :year => 2026).weeks, 52)
    assert_equal(Calendar.thirteen_week(:defined_by => :ends_last_saturday_in_july, :year => 2025).weeks, 52)
    assert_equal(Calendar.thirteen_week(:defined_by => :ends_last_saturday_in_july, :year => 2000).weeks, 52)
    assert_equal(Calendar.thirteen_week(:defined_by => :ends_last_saturday_in_july, :year => 2001).weeks, 52)
  end
  
  test "Check that the thirteen week calendars start with correct day of week" do
    days = [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
    months = Date::MONTHS.collect {|k, v| k}
    (1..500).each do
      d = rand(days.length - 1)
      m = rand(months.length - 1)
      c = Calendar.thirteen_week(:year_starts_in => months[m], :year => 1900 + rand(200), :week_starts_on => days[d])
      assert_equal(days.at(c.first.wday), days[d])
      assert_equal(Date::MONTHS.index(c.first.month), months[m])
    end
  end
  
  test "Check nth_x_day functions in thirteen week calendar" do
    cal = Calendar.thirteen_week.year(2009)
    assert_equal(cal.first, Date.new(2008, 1, 6))
    assert_equal(cal.last, Date.new(2009, 1, 3))
    assert_equal(cal.first_monday, Date.new(2008, 1, 7))
    assert_equal(cal.last_monday, Date.new(2008, 12, 29))
    assert_equal(cal.second_thursday, Date.new(2008, 1, 17))
    assert_equal(cal.nth_x_day(-2, :wednesday), Date.new(2008, 12, 24))
  end
  
  test "Check that calendar quarters are correct for each starting month of gregorian calendar" do
    Date::MONTHS.collect {|k, v| k}.each do |month|
      cal = Calendar.gregorian(:year_starts_in => month, :year => 2009)
      q1 = cal.quarter(1)
      q2 = cal.quarter(2)
      q3 = cal.quarter(3)
      q4 = cal.quarter(4)
      assert_equal(q1.first, cal.first)
      assert_equal(q2.first, cal.first >> 3)
      assert_equal(q3.first, cal.first >> 6)
      assert_equal(q4.first, cal.first >> 9)
    end
  end
  
  test "That the default quarter is correct" do
    c = Calendar.gregorian(:year_starts_in => :january, :week_starts_on => :sunday)
    today = Date.new(2009, 1, 23)
    assert_equal(1, c.quarter_of_year(today))
    q = c.quarter(c.quarter_of_year(today))
    assert(q.range.include?(today))
    assert_equal(Date.new(2009, 1, 1)..Date.new(2009,1,31), q.month(1).first..q.month(1).last)
  end
  
  test "That html is generated on December start months" do
    c = Calendar.gregorian(:year_starts_in => :december, :week_starts_on => :sunday)
    today = Date.new(2009, 1, 23)
    assert_equal(c.quarter_of_year(today), 1)
    assert(c.quarter(c.quarter_of_year(today)).to_html.size > 0)
  end
  
  test "That a january year has 3 months in quarter 1" do
    c = Calendar.gregorian(:year_starts_in => :january, :week_starts_on => :sunday)
    today = Date.new(2009, 1, 23)
    assert_equal(3, c.quarter(c.quarter_of_year(today)).months)
  end
end
