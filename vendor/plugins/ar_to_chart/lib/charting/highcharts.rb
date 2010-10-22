module Charting
  module Highcharts
    class Renderer
      DEFAULT_OPTIONS = {
        :container_height      => '200px',
        :type                  => :area
      }
    
      attr_accessor :categories, :series, :options, :chart
      
      # Generate Highchart based charts.  CSS is used
      # for the colouring.
      #
      # ====Parameters
      #
      #   data_source:      The active record result set
      #   category_column:  The column used for the x-axis
      #   data_columns:     one column name or an array of column names to be charted or a hash
      #                     with pairs of :column_names => :series_type
      #   options:          options hash 
      #
      # ====Options
      #
      #   :container_height   Requested height of the container.  Defaults to 200px
      #
      def initialize(data_source, category_column, data_columns, options = {})
        @options = DEFAULT_OPTIONS.merge(options)
        @options[:container] = @options[:container] || generate_container_name
        @data_columns = data_columns.respond_to?(:each) ? data_columns : [data_columns]
        @chart = chart_class.new(data_source, category_column, @data_columns, @options)
      end
      
      def container
        <<-EOF
          <div id='#{container_id}' style="height:#{options[:container_height]}"></div>
        EOF
      end
      
      def script
        <<-EOF
          $(document).ready(function() {
            chart = new tracksterChart;
            #{chart.to_js}
          });     
        EOF
      end
      
      def to_html
        <<-EOF
          #{container}
          <script type="text/javascript">
            #{script}
          </script>
        EOF
      end
    
      def chart_class
        @chart_class ||= "Charting::Highcharts::#{options[:type].to_s.titleize}".constantize
      end

      def container_id
        @container_id ||= options[:container]
      end
      
    private
      def generate_container_name
        "chart_" + ActiveSupport::SecureRandom.hex(3)
      end
      
    end
  end
end
