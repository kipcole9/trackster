module Charting
  module Highcharts
    class Area < Charting::Highcharts::Base
    
      def categories
        # Generate categories
        data_source.inject([]) do |categories, row|
          categories << row.format_column(category_column).try(:strip_tags).try(:strip)
        end
      end
    
      def series
        # Generate data series array (for each column)
        data_columns.inject([]) do |series, column|
          series_data = data_source.inject([]) do |series_data, row|
            series_data << row[column].to_i
          end
          series << {:name => series_name(column), :data => series_data}
        end
      end

    end
  end
end
      
