# Parse parameters (usually from a request via ActionController) into
# chain of named scopes
#
# Format of query parameters:
# => by=dim1,dim2,dim3    dimensions
# => metric=metric1       a metric (only one at this time)
# => from=
# => to=

class Period
  extend ActiveSupport::Memoizable

  def in_text_from_params(params)
    return I18n.t("reports.period.#{params[:period]}") if params[:period]
    range = from_params(params)
    I18n.t('reports.period.time_period', :from => range.first.to_date, :to => range.last.to_date, :default => range.to_s)
  end
  memoize :in_text_from_params

  def to_scope(params)
    metric      = metric_from_params(params)
    dimensions  = dimensions_from_params(params)
    period      = from_params(params)
    send(metric).send(:by, dimensions).send(:between, period)
  end

  def metric_from_params(params)
    metric = params[:metric]
    raise ArgumentError, "Invalid metric '#{metric}'" unless valid_metric?(metric)
    metric.to_sym
  end

  def dimensions_from_params(params)
    return [] unless param = params[:by]
    param.split(',').map(&:strip).map(&:to_sym)
  end

  def from_params(params = {})
    default_from  = (today - 30.days).beginning_of_day
    default_to    = today.end_of_day
    if params[:period]
      from, to = from_param(params[:period], default_from..default_to)
    else
      to = date_from_param(params[:to], default_to)
      from = date_from_param(params[:from], default_from)
    end       
    from..to
  end
  memoize :from_params

  def date_from_param(date, default)
    return default unless date
    return date.to_date if date.is_a?(Date) || date.is_a?(Time)
    Time.parse(date) rescue default
  end
  memoize :date_from_param

  def from_param(period, default)
    return default.first, default.last unless period
    period_range = case period.to_sym
      when :today          then today.beginning_of_day..today.end_of_day
      when :yesterday      then yesterday.beginning_of_day..yesterday.end_of_day
      when :this_week      then first_day_of_this_week.beginning_of_day..last_day_of_this_week.end_of_day
      when :this_month     then first_day_of_this_month.beginning_of_day..last_day_of_this_month.end_of_day
      when :this_year      then first_day_of_this_year.beginning_of_day..last_day_of_this_year.end_of_day
      when :last_week      then first_day_of_last_week.beginning_of_day..last_day_of_last_week.end_of_day
      when :last_month     then first_day_of_last_month.beginning_of_day..last_day_of_last_month.end_of_day
      when :last_year      then first_day_of_last_year.beginning_of_day..last_day_of_last_year.end_of_day
      when :last_30_days   then (today - 30.days).beginning_of_day..today.end_of_day
      when :last_12_months then (today - 12.months).beginning_of_day..today.end_of_day
      when :lifetime       then beginning_of_epoch.beginning_of_day..today.end_of_day;
      else default
    end
    # Rails.logger.info "Period from param: '#{period}': #{period_range.first}-#{period_range.last}"
    return period_range.first, period_range.last
  end
  memoize :from_param
  
  # Basic markers
  def today
    Time.zone.now.to_date
  end
  memoize :today

  def yesterday
    today - 1.day
  end
  memoize :yesterday

  def tomorrow
    today + 1.day
  end
  memoize :tomorrow

  def beginning_of_epoch
    today - 20.years
  end
  memoize :beginning_of_epoch

  # This week
  def first_day_of_this_week
    today - today.wday.days
  end
  memoize :first_day_of_this_week

  def last_day_of_this_week
    first_day_of_this_week + 7.days
  end
  memoize :last_day_of_this_week

  # This month
  def first_day_of_this_month
    Date.new(today.year, today.month, 1)
  end
  memoize :first_day_of_this_month

  def last_day_of_this_month
    first_day_of_this_month + 1.month - 1.day
  end
  memoize :last_day_of_this_month

  # Last week
  def first_day_of_last_week
    first_day_of_this_week - 7.days
  end
  memoize :first_day_of_last_week

  def last_day_of_last_week
    first_day_of_last_week + 7.days
  end
  memoize :last_day_of_last_week

  # Last month
  def first_day_of_last_month
    last_month = Date.today - 1.month
    Date.new(last_month.year, last_month.month, 1)
  end
  memoize :first_day_of_last_month

  def last_day_of_last_month
    first_day_of_last_month + 1.month - 1.day
  end
  memoize :last_day_of_last_month

  # This year
  def first_day_of_this_year
    Date.new(today.year, 1, 1)
  end
  memoize :first_day_of_this_year

  def last_day_of_this_year
    Date.new(today.year, 12, 31)
  end
  memoize :last_day_of_this_year
  
  # Last year
  def first_day_of_last_year
    Date.new(today.year - 1, 1, 1)
  end
  memoize :first_day_of_last_year

  def last_day_of_last_year
    Date.new(first_day_of_last_year.year, 12, 31)
  end
  memoize :last_day_of_last_year
  
  # Clear the saved instance which we should do at the start
  # of each Rails request
  def self.clear
    Thread.current[:period] = nil
  end
  
  # Called when we're configured as a before_filter which we need to
  # ensure our thread data is ours and no left over from somebody else
  def self.filter(controller)
    clear
  end

  # Arrange for instance methods to be called as if class methods.  Make threadsafe.
  def self.method_missing(method, *args)
    Thread.current[:period] = new unless Thread.current[:period]
    self.instance_methods.include?(method.to_s) ? Thread.current[:period].send(method, *args) : super
  end
end
   
