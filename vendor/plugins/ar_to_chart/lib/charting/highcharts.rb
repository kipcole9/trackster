module Charting
  class Highcharts
    DEFAULT_OPTIONS = {
      :container_height      => '200px'
    }
    
    attr_accessor :categories, :series, :options, :chart
    
    # Generate Highchart based charts.  CSS is used
    # for the colouring.
    #
    # ====Parameters
    #
    #   data_source: the active record result set
    #   columns: one column name or an array of column names to be charted or a hash
    #            with pairs of :column_names => :series_type
    #
    # ====Options
    #
    def initialize(data_source, category_column, data_columns, options = {})
      @options = DEFAULT_OPTIONS.merge(options)
      @options[:container] = "chart_" + ActiveSupport::SecureRandom.hex(5)
      @data_columns = data_columns.respond_to?(:each) ? data_columns : [data_columns]
      @chart = chart_class.new(data_source, category_column, @data_columns, @options)
    end
    
    def to_html
      <<-EOF
        <div id='#{container}' style="height:#{options[:container_height]}"></div>
        <script type="text/javascript">
          $(document).ready(function() {
            chart = new tracksterChart;
            #{chart.to_js}
          });
        </script>      
      EOF
    end
    
    def chart_class
      @chart_class ||= "Charting::Highcharts::#{(options[:type] || :area).to_s.titleize}".constantize
    end

    def container
      options[:container]
    end
  end
end







# How Highcharts maps for localization - we should update this for each chart.
# Found as chart.options.lang
#
# lang: {
#   loading: 'Loading...',
#   months: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 
#       'August', 'September', 'October', 'November', 'December'],
#   weekdays: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
#   decimalPoint: '.',
#   resetZoom: 'Reset zoom',
#   resetZoomTitle: 'Reset zoom level 1:1',
#   thousandsSep: ','
# },