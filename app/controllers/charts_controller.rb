class ChartsController < ApplicationController
  
  def index
    #@graph = open_flash_chart_object("100%","50%","/charts/line_code")
    @graph = open_flash_chart_object("100%","200","/charts/line_code")
  end

  def graph_code
    title = Title.new("MY TITLE")
    bar = BarGlass.new
    bar.set_values([1,2,3,4,5,6,7,8,9])
    chart = OpenFlashChart.new
    #chart.set_title(title)
    chart.add_element(bar)
    render :text => chart.to_s
  end
  
  def line_code
    # based on this example - http://teethgrinder.co.uk/open-flash-chart-2/data-lines-2.php
    title = Title.new("Multiple Lines")

    series_1 = current_account.sites.first.tracks.opened_emails.by(:day)
    series_2 = current_account.sites.first.tracks.clicked_emails.by(:day)
    
    data1 = [2,4,7,23,9,56,4,5,6,7,8,5,3,45,7,8,6,2,3,4,6,8,5,45,43,7,5,24]
    data2 = [2,8,2,43,2,34]

    line_dot = AreaLine.new
    line_dot.text = "Opened"
    line_dot.width = 4
    line_dot.colour = '#DFC329'
    line_dot.dot_size = 5
    
    data1[1] = Point.new(20, "This is my tip", '#DFC329')
    line_dot.values = data1
    line_dot.tooltip = "Tooltip Title\nTooltip with #val# at #x_label#"

    line_hollow = LineHollow.new
    line_hollow.text = "Clicked"
    line_hollow.width = 1
    line_hollow.colour = '#6363AC'
    line_hollow.dot_size = 5
    line_hollow.values = data2

    y = YAxis.new
    y.set_range(0,100,10)
    y.set_grid_colour( '#777777' )
    y.set_steps( 200 )
    y.set_offset(0)

    x = XAxis.new
    #x.labels = series_1.dup.map(&:tracked_at)
    x.set_grid_colour( '#ffffff' );
    
    x_legend = XLegend.new("MY X Legend")
    x_legend.set_style('{font-size: 20px; color: #778877}')

    y_legend = YLegend.new("MY Y Legend")
    y_legend.set_style('{font-size: 20px; color: #770077}')

    chart = OpenFlashChart.new
    chart.set_bg_colour("#FFFFFF")
    #chart.set_title(title)
    #chart.set_x_legend(x_legend)
    #chart.set_y_legend(y_legend)
    chart.y_axis = y
    chart.x_axis = x

    chart.add_element(line_dot)
    chart.add_element(line_hollow)

    render :text => chart.to_s
  end
  
  
end
