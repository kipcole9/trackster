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
        default_from = Date.today - 30.days
        default_to = Date.today
        if params[:period]
          from, to = period_from_param(params[:period], default_from..default_to)
        else
          to = date_from_param(params[:to], default_to)
          from = date_from_param(params[:from], default_from)
        end       
        from..to
      end
      
      def period_in_text_from_params(params)
        return I18n.t("reports.period.#{params[:period]}") if params[:period]
        range = period_from_params(params)
        I18n.t('reports.period.time_period', :from => range.first.to_date, :to => range.last.to_date, :default => range.to_s)
      end
      
      def date_from_param(date, default)
        return default unless date
        return date.to_date if date.is_a?(Date) || date.is_a?(Time)
        Time.parse(date) rescue default
      end
      
      def period_from_param(period, default)
        return default unless period
        period = case period
          when 'today'          then today..tomorrow
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
        return period.first, period.last
      end
      
      def today
        @today ||= Time.zone.now.to_date.to_time
      end
      
      def tomorrow
        @tomorrow ||= today + 1.day - 1.second   # Since today converted to time means midnight today - and no traffic
      end
      
      def beginning_of_epoch
        (today - 20.years).to_time
      end
      
      def first_day_of_this_week
        (today - today.wday).to_time
      end
    
      def first_day_of_this_month
        Date.new(today.year, today.month, 1).to_time
      end
      
      def first_day_of_last_week
        (first_day_of_this_week - 7.days).to_time
      end
      
      def last_day_of_last_week
        first_day_of_last_week + 7.days - 1.second
      end
      
      def first_day_of_last_month
        last_month = Date.today - 1.month
        Date.new(last_month.year, last_month.month, 1).to_time
      end
      
      def last_day_of_last_month
        first_day_of_last_month + 1.month - 1.second
      end
    
      def first_day_of_this_year
        Date.new(today.year, 1, 1).to_time
      end
      
      def first_day_of_last_year
        Date.new(today.year - 1, 1, 1).to_time
      end
      
      def last_day_of_last_year
        first_day_of_last_year + 1.year - 1.second
      end
    end
    
    module InstanceMethods
      
    end
  end
end