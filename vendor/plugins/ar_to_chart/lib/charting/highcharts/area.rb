module Charting
  class Highcharts
    class Area
      MAX_X_LABELS  = 10
      attr_reader :data_source, :category_column, :data_columns, :options
      
      def initialize(data_source, category_column, data_columns, options = {})
        @data_source      = data_source
        @category_column  = category_column
        @data_columns     = data_columns
        @options          = options
      end
      
      def categories
        # Generate categories
        data_source.inject([]) do |categories, row|
          categories << row.format_column(category_column).strip_tags.strip
        end
      end
      
      def series
        # Generate data series array (for each column)
        data_columns.inject([]) do |series, column|
          series_data = data_source.inject([]) do |series_data, row|
            series_data << (row[column].is_a?(String) ? row[column].to_i : row[column])
          end
          series_name = data_source.first.class.human_attribute_name(column)
          series << {:name => series_name, :data => series_data}
        end
      end
      
      def chart_options
        {
          :x_axis => nil, 
          :y_axis => nil, 
          :x_step => options[:x_step] || (data_source.size / MAX_X_LABELS)
        }
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
      
