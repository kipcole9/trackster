# Parse parameters (usually from a request via ActionController) into
# chain of named scoped
#
# Format of query parameters:
# => by=dim1,dim2,dim3    dimensions
# => metric=metric1       a metric (only one at this time)
# => from=
# => to=

module Analytics
  module ParamParser
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end
      
    module ClassMethods  
      def params_to_scope(params)
        metric      = metric_from_params(params)
        dimensions  = dimensions_from_params(params)
        period      = period_from_params(params)
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
      
      def period_from_params(params)
        return nil unless params[:from] || params[:max] || params[:to] || params[:period]
        default_to = Time.now
        default_from = default_to - 30.days
        if params[:period]
          from, to = period_from_param(params[:period], default_from..default_to)
        else
          to = date_from_param(params[:to], params[:max] || default_to)
          from = date_from_param(params[:from], default_from)
        end       
        from..to
      end
      
      def date_from_param(date, default)
        return default unless date
        return date.to_date if date.is_a?(Date) || date.is_a?(Time)
        Time.parse(date) rescue default
      end
      
      def period_from_param(period, default)
        return default unless period
        today = Date.today + 1.day   # Since today converted to time means midnight today - and no traffic
        period = case period
          when 'today'          then today..today
          when 'this_week'      then first_day_of_this_week..today
          when 'this_month'     then first_day_of_this_month..today
          when 'this_year'      then first_day_of_this_year..today
          when 'last_30_days'   then (today - 30.days)..today
          when 'last_12_months' then (today - 12.months)..today
          when 'lifetime'       then (Date.today - 20.years)..today;
          else default
        end
        return period.first, period.last
      end
      
      def first_day_of_this_week
        Date.today - Date.today.wday
      end
    
      def first_day_of_this_month
        today = Date.today
        Date.new(today.year, today.month, 1)
      end
    
      def first_day_of_this_year
        today = Date.today
        Date.new(today.year, 1, 1)
      end
    end
    
    module InstanceMethods
      
    end
  end
end