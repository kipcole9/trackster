module Charting
  module Highcharts
    class Pie < Charting::Highcharts::Base

      def series
        # Generate data series array (for each column)
        data_columns.inject([]) do |series, column|
          series_data = data_source.inject([]) do |series_data, row|
            series_data << [row.format_column(category_column).strip_tags.strip, (row[column].is_a?(String) ? row[column].to_i : row[column])]
          end
          series << {:type => chart_type, :name => series_name(column), :data => series_data}
        end
      end

      def categories
        nil
      end

    end
  end
end
