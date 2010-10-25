module Charting
  module Highcharts
    class Base
      attr_reader :data_source, :category_column, :data_columns, :options
      
      MAX_X_LABELS  = 10
      DEFAULT_OPTIONS = {

      }
      
      def initialize(data_source, category_column, data_columns, options = {})
        @data_source      = data_source
        @category_column  = category_column
        @data_columns     = data_columns
        @options          = DEFAULT_OPTIONS.merge(options)
        @options[:x_step] ||= (data_source.size.to_f / MAX_X_LABELS.to_f).round
      end
    
      def chart_options
        {
          :x_axis => options[:x_axis_title], 
          :y_axis => options[:y_axis_title], 
          :x_step => options[:x_step]
        }
      end
    
      # Define in concrete subclass
      def series
        {}
      end
      
      # Define in concrete subclass
      def categories
        {}
      end
      
      def series_name(column)
        data_source.first.class.human_attribute_name(column)
      end
      
      def chart_type
        @chart_type ||= self.class.name.split('::').last.downcase
      end

      def container
        options[:container]
      end
    
      def to_js
        <<-EOF
          chart.render('#{container}', 
            #{categories.to_json}, 
            #{series.to_json},
            #{chart_options.to_json}
          );
        EOF
      end
    end
  end
end