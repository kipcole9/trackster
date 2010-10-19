module Charting
  class Highchart
    
    # Generate Highchart based charts (non-flash).  CSS is used
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
    #   :regression => true       Plot a regression line for the data?
    #   :tooltip => '....'        JS for the tooltip that is EVAL'd on the client
    #   :normalize => range       Normalize data to this range for all series
    def initialize(data_source, columns, options = {})
      # Generate container
      # Generate categories
      # Generate data series array (for each column)
      
      # For date-based use a TimeSeries plot (including by-hour, by-day, by-date etc etc)
      # For others use a category based plot
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