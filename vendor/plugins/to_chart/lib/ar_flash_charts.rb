module Trackster
  class FlashChart

    include OpenFlashChart::View
    include OpenFlashChart::Controller
    include OpenFlashChart  
      
    def initialize(data_source, x, y, options = {})
      @graph = open_flash_chart_embedded("100%","200","TestDiv", line_code)
    end
    
    def render_chart
      @graph
    end

    def graph_code
      #title     = Title.new("MY TITLE")
      #bar       = BarGlass.new
      bar = AreaHollow.new
      bar.set_values([2,4,7,23,9,56,4,5,6,7,8,5,3,45,7,8,6,2,3,4,6,8,5,45,43,7,5,24])
      
      y = YAxis.new
      y.set_range(0,60,20)
      y.set_grid_colour( '#aaaaaa' )
      y.set_offset(0)
      
      chart     = OpenFlashChart.new
      chart.set_bg_colour("#dddddd")
      chart.y_axis = y
      #chart.set_title(title)
      chart.add_element(bar)
      chart.to_s
    end

    def line_code
      # based on this example - http://teethgrinder.co.uk/open-flash-chart-2/data-lines-2.php
      #title = Title.new("AreaLine")
      
      data1 = [2,4,7,23,9,56,4,5,6,7,8,5,3,45,7,8,6,2,3,4,6,8,5,45,43,7,5,24]

      line_dot = Line.new
      line_dot.text = "Opened"
      line_dot.width = 4
      line_dot.colour = '#DFC329'
      line_dot.dot_size = 5
      line_dot.set_values(data1)

      y = YAxis.new
      y.set_range(0,60,20)
      y.set_grid_colour( '#ffffff' )

      x = XAxis.new
      #x.labels = series_1.dup.map(&:tracked_at)
      x.set_grid_colour( '#ffffff' );

      chart = OpenFlashChart.new
      chart.set_bg_colour("#dddddd")
      chart.y_axis = y
      chart.x_axis = x
      
      # The data series
      chart.add_element(line_dot)

      chart.to_s
    end
  end
end    