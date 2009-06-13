# TODO:
# HTML output is incorrect for the calendar when "week starts on full week" for gregorian calendars.  In this case
# we don't show the week that includes the 1st of the month!!!!  And we also show a week that is after the
# end of the month.
#
# The M1 and Q1 markers on months are incorrect (proabbly an underlying calendar issue)
#
# Need to provide links to scroll the calendar (using Ajax)


module HtmlOutput
  # Calendar is produced for the current calendar's range. Therefore this
  # coud be a year, quarter, month or week calendar.  Calendars are traditionally
  # displayed by month, so in our case we'll only honor requests for
  # year, quarter and month
  def to_html(options={}, &block)
    default_options = {:calendar      => "calendar",
                       :month_name    => "monthName",
                       :month_tags    => "monthTags",
                       :day_name      => "dayName",
                       :day           => "day",
                       :weekday       => "weekday",
                       :weekend       => "weekendDay",
                       :other_month   => "otherMonth",
                       :today         => "today",
                       :class_prefix  => ""
                       }
    xhtml = []
    if calendar_range == :month
      xhtml << make_html_month_calendar(default_options.merge(options), &block)
    else
      1.upto(months) do |m| 
        xhtml << month(m).make_html_month_calendar(default_options.merge(options), &block)
      end
    end
    xhtml.join
  end

protected
  def make_html_month_calendar(options, &block)
    raise ArgumentError, "calendars can only be produced for a month" unless calendar_range == :month
    xhtml = []
    prefix = options[:prefix]
    cal = Builder::XmlMarkup.new(:target => xhtml, :indent => 2)
    cal.div(:class => "calendarWrapper") do 
      cal.table(:class => "#{prefix}#{options[:calendar]}", :border => 0, :cellspacing => 0, :cellpadding => 0) do
        cal.thead do
          cal.tr do
            cal.th("m#{month_of_year(range.last)}", :class => "#{prefix}#{options[:month_tags]}")
            cal.th(I18n.t(month_name, :scope => [:calendar, :months]).capitalize, :colspan => 5, :class => "#{prefix}#{options[:month_name]}")
            cal.th("q#{quarter_of_year(range.last)}", :class => "#{prefix}#{options[:month_tags]}")
          end

          cal.tr(:class => "#{prefix}#{options[:day_name]}") do
            days_of_week.each { |d| cal.th(I18n.t(d, :scope => [:calendar, :shortdays]).capitalize, :scope => 'col') }
          end
        end

        cal.tbody do
          (1..weeks + additional_calendar_weeks).each do |week_number|
            this_week = week_without_bounds(week_number)
            cal.tr do
              (1..Calendar::DAYS_IN_WEEK).each do |day_of_week|
                today = this_week.first + day_of_week - 1
                css_classes = ["#{prefix}#{options[:day]}"]
                css_classes << "#{prefix}#{options[:weekday]}"      if is_work_day?(today)
                css_classes << "#{prefix}#{options[:weekend]}"      if is_weekend?(today)
                css_classes << "#{prefix}#{options[:other_month]}"  if !range.include?(today)
                css_classes << "#{prefix}#{options[:today]}"        if today == Time.now.to_date
                css_class = css_classes.join(' ')
                this_day = block_given? ? block.call(today, css_class) : today.day.to_s
                cal.td(this_day, :class => css_class)
              end
            end
          end
        end
      end
    end

    xhtml.join
  end
end