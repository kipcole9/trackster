module Trackster
  class FlashChart

    include OpenFlashChart::View
    include OpenFlashChart::Controller
    include OpenFlashChart  
    
    DEFAULT_OPTIONS = { :type               => Line, 
                        :width              => 4, 
                        :dot_size           => 5, 
                        :colour             => '#DFC329',
                        :background_colour  => '#dddddd',
                        :grid_colour        => '#ffffff',
                        :grid_division      => 5
                      }
      
    def initialize(data_source, column, labels = nil, options = {})
      options = DEFAULT_OPTIONS.merge(options)
      div_name = options[:id] || "chart_" + ActiveSupport::SecureRandom.hex(5)
      data = graph_data(data_source, x, y, options)
      @graph = open_flash_chart_embedded("100%","200", div_name, data.to_s)
    end
    
    def render_chart
      @graph
    end

    def graph_data(data_source, column, labels, options)
      data_set          = data_source.map(&column.to_sym)
      series            = options[:type].new
      series.text       = options[:text] if options[:text]
      series.width      = options[:width]
      series.colour     = options[:colour]
      series.dot_size   = options[:dot_size]
      series.set_values(data_set)

      y = YAxis.new
      y_max = data_set.max
      y_min = [data_set.min, 0].min
      y.set_range(y_min, y_max, (y_max / options[:grid_division]).to_i)
      y.set_grid_colour(options[:grid_colour])

      x = XAxis.new
      #x.labels = series_1.dup.map(&:tracked_at)
      x.set_grid_colour(options[:grid_colour]);

      chart = OpenFlashChart.new
      chart.set_bg_colour(options[:background_colour])
      chart.y_axis = y
      chart.x_axis = x
      
      # The data series
      chart.add_element(series)
      chart
    end
  end
end    