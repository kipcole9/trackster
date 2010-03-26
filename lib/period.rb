# Parse parameters (usually from a request via ActionController) into
# chain of named scoped
#
# Format of query parameters:
# => by=dim1,dim2,dim3    dimensions
# => metric=metric1       a metric (only one at this time)
# => from=
# => to=

class Period
  include Singleton
  extend ActiveSupport::Memoizable

  def in_text_from_params(params)
    return I18n.t("reports.period.#{params[:period]}") if params[:period]
    range = from_params(params)
    I18n.t('reports.period.time_period', :from => range.first.to_date, :to => range.last.to_date, :default => range.to_s)
  end

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
    param = params[:by]
    return [] unless param
    param.split(',').map(&:strip).map(&:to_sym)
  end

  def from_params(params = {})
    default_from = today - 30.days
    default_to = today
    if params[:period]
      from, to = from_param(params[:period], default_from..default_to)
    else
      to = date_from_param(params[:to], default_to)
      from = date_from_param(params[:from], default_from)
    end       
    from..to
  end

  def date_from_param(date, default)
    return default unless date
    return date.to_date if date.is_a?(Date) || date.is_a?(Time)
    Time.parse(date) rescue default
  end

  def from_param(period, default)
    return default.first, default.last unless period
    period_range = case period
      when 'today'          then today..tomorrow
      when 'yesterday'      then yesterday..today
      when 'this_week'      then first_day_of_this_week..tomorrow
      when 'this_month'     then first_day_of_this_month..tomorrow
      when 'this_year'      then first_day_of_this_year..tomorrow
      when 'last_week'      then first_day_of_last_week..last_day_of_last_week
      when 'last_month'     then first_day_of_last_month..last_day_of_last_month
      when 'last_year'      then first_day_of_last_year..last_day_of_last_year
      when 'last_30_days'   then (today - 30.days)..tomorrow
      when 'last_12_months' then (today - 12.months)..tomorrow
      when 'lifetime'       then beginning_of_epoch..tomorrow;
      else default
    end
    # Rails.logger.info "Period from param: '#{period}': #{period_range.first}-#{period_range.last}"
    return period_range.first, period_range.last
  end
  memoize :from_param

  def today
    Time.zone.now.to_date.to_time
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

  def first_day_of_this_week
    today - today.wday.days
  end
  memoize :first_day_of_this_week

  def first_day_of_this_month
    Date.new(today.year, today.month, 1).to_time
  end
  memoize :first_day_of_this_month

  def first_day_of_last_week
    first_day_of_this_week - 7.days
  end
  memoize :first_day_of_last_week

  def last_day_of_last_week
    first_day_of_last_week + 7.days - 1.second
  end
  memoize :last_day_of_last_week

  def first_day_of_last_month
    last_month = Date.today - 1.month
    Date.new(last_month.year, last_month.month, 1).to_time
  end
  memoize :first_day_of_last_month

  def last_day_of_last_month
    first_day_of_last_month + 1.month - 1.second
  end
  memoize :last_day_of_last_month

  def first_day_of_this_year
    Date.new(today.year, 1, 1).to_time
  end
  memoize :first_day_of_this_year

  def first_day_of_last_year
    Date.new(today.year - 1, 1, 1).to_time
  end
  memoize :first_day_of_last_year

  def last_day_of_last_year
    first_day_of_last_year + 1.year - 1.second
  end
  memoize :last_day_of_last_year

  def self.method_missing(method, *args)
    self.instance_methods.include?(method.to_s) ? self.instance.send(method, *args) : super
  end
end
   
