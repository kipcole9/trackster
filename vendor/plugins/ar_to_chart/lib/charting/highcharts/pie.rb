module Charting
  class Highcharts
    class Pie
      
      attr_reader :data_source, :category_column, :data_columns, :options
      
      def initialize(data_source, category_column, data_columns, options = {})
        @data_source      = data_source
        @category_column  = category_column
        @data_columns     = data_columns
        @options          = options
      end
      
      def series
        # Generate data series array (for each column)
        data_columns.inject([]) do |series, column|
          series_data = data_source.inject([]) do |series_data, row|
            series_data << [row.format_column(category_column), row[column]]
          end
          series_name = data_source.first.class.human_attribute_name(column)
          series << {:type => chart_type, :name => series_name, :data => series_data}
        end
      end
      
      def chart_options
        {:x_axis => nil, :y_axis => nil}
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
            null, 
            #{series.to_json},
            #{chart_options.to_json}
          );
        EOF
      end

    end
  end
end

#  series: [{
#    type: 'pie',
#    name: 'Browser share',
#    data: [
#       ['Firefox',   45.0],
#       ['IE',       26.8],
#       {
#          name: 'Chrome',    
#          y: 12.8,
#          sliced: true,
#          selected: true
#       },
#       ['Safari',    8.5],
#       ['Opera',     6.2],
#       ['Others',   0.7]
#    ]
# }]
      
