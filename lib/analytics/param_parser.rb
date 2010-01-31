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
        return nil unless params[:from] || params[:max] || params[:to]
        to = date_from_param(params[:to], params[:max] || Time.now)
        from = date_from_param(params[:from], to - 30.days)        
        from..to
      end
      
      def date_from_param(date, default)
        return default unless date
        return date.to_date if date.is_a?(Date) || date.is_a?(Time)
        Time.parse(date) rescue default
      end
    end
    
    module InstanceMethods
      
    end
  end
end