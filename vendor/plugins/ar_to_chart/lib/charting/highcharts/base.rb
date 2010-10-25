module Charting
  module Highcharts
    class Base
      attr_reader :data_source, :category_column, :data_columns, :options
      
      WEEKEND         = [0,6]   # The days of the week that are the weekend (Sun, Sat)
      AXIS_START_UNIT = 0.5     # Where highcharts starts its x-axis in axis units
      MAX_X_LABELS    = 10      # Display no more than this number of category labels
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
          :x_step => options[:x_step],
          :x_plot_bands => weekend_plot_bands
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
      
      # Returns a plotbands definition for the data source
      # Only if the category column is a date or datetime
      def weekend_plot_bands
        return unless options[:weekend_plot_bands] && data_source.first[category_column].respond_to?(:to_date)
        x_plot_bands = data_source.inject_with_index([]) do |plot_bands, row, index|
          if WEEKEND.include?(row[category_column].to_date.wday)
            plot_bands << {:from => (index + AXIS_START_UNIT - 1), :to => (index + AXIS_START_UNIT)}
          end
          plot_bands
        end
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